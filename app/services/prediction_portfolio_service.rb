require "date"

class PredictionPortfolioService
  PAYLOAD_PATH = Rails.root.join("public/customers_kaminari.json")
  FORECAST_HORIZON = 6

  def call
    payload = JSON.parse(PAYLOAD_PATH.read)
    monthly_revenue = payload.dig("charts", "monthly_customer_revenue") || []
    monthly_profit = payload.dig("charts", "monthly_gross_profit") || []
    customers = payload.fetch("customers")
    carts = payload.dig("tables", "cart_recovery_table") || []
    category_performance = payload.dig("tables", "category_performance") || []
    product_ranking = payload.dig("tables", "product_ranking") || []
    period_end = Date.parse(payload.dig("metadata", "period_end"))

    revenue_model = linear_forecast(monthly_revenue, "revenue")
    profit_model = linear_forecast(monthly_profit, "gross_profit")
    scored_customers = customer_scores(customers, period_end)
    scored_carts = cart_recovery_scores(carts)
    city_opportunities = city_opportunities(scored_customers)
    product_type_focus = product_type_focus(carts, category_performance, product_ranking)

    {
      resource: "predictive_dashboard",
      generated_from: {
        api: "/api/customers",
        payload: "public/customers_kaminari.json",
        source_dataset: payload.dig("metadata", "dataset_name"),
        period_start: payload.dig("metadata", "period_start"),
        period_end: payload.dig("metadata", "period_end")
      },
      orchestration_cycle: orchestration_cycle,
      model_cards: model_cards(revenue_model, city_opportunities, scored_customers, product_type_focus),
      forecast: {
        revenue: revenue_model,
        gross_profit: profit_model,
        next_90_days_revenue: revenue_model.fetch(:forecast).first(3).sum { |row| row.fetch(:prediction) }.round(2),
        previous_90_days_revenue: monthly_revenue.last(3).sum { |row| row.fetch("revenue").to_f }.round(2)
      },
      customer_propensity: {
        scored_count: scored_customers.length,
        top_opportunities: scored_customers.first(8),
        city_opportunities: city_opportunities.first(8),
        retention_watchlist: scored_customers.sort_by { |row| -row.fetch(:churn_risk_score) }.first(8),
        features: [
          "completed_orders",
          "total_revenue",
          "average_ticket",
          "days_since_last_purchase",
          "customer_lifetime_days"
        ]
      },
      cart_recovery: {
        expected_recovered_revenue: scored_carts.sum { |row| row.fetch(:expected_revenue) }.round(2),
        candidates: scored_carts.first(8),
        product_type_focus: product_type_focus.first(8)
      },
      decision_notes: decision_notes(revenue_model, city_opportunities, product_type_focus)
    }
  end

  private

  def orchestration_cycle
    [
      {
        agent: "Orquestrador",
        decision: "Manter a pagina em /dashboards/previsoes e expor o contrato em /api/predictions.",
        integration: "Rails renderiza a experiencia; JavaScript consome o JSON preditivo e tem fallback visual."
      },
      {
        agent: "Cientista de dados",
        decision: "Usar modelos transparentes para portfolio: regressao linear temporal, score de propensao e priorizacao de carrinhos.",
        integration: "Cada previsao retorna metrica de erro, features e limitacao para facilitar auditoria."
      },
      {
        agent: "Integrador de API",
        decision: "Derivar tudo do payload governado existente para evitar dependencia externa em tempo de pagina.",
        integration: "O mesmo dataset que alimenta /api/customers passa a alimentar modelos e acoes comerciais."
      }
    ]
  end

  def model_cards(revenue_model, city_opportunities, scored_customers, product_type_focus)
    [
      {
        name: "Forecast de receita mensal",
        kind: "Regressao linear temporal",
        target: "revenue",
        metric: "MAPE",
        score: revenue_model.dig(:metrics, :mape_percent),
        business_action: "Planejar meta de faturamento, estoque e campanhas dos proximos 6 meses."
      },
      {
        name: "Propensao de recompra",
        kind: "Score supervisionavel por regras de negocio",
        target: "repeat_purchase_probability",
        metric: "Cidades ranqueadas",
        score: city_opportunities.length,
        business_action: "Ativar campanhas por praça onde a recompra média e o valor previsto são maiores."
      },
      {
        name: "Risco de churn",
        kind: "Score de recencia, frequencia e valor",
        target: "churn_risk",
        metric: "Clientes em alerta",
        score: scored_customers.count { |row| row.fetch(:churn_risk_score) >= 65 },
        business_action: "Disparar campanhas de retencao antes que clientes recorrentes esfriem."
      },
      {
        name: "Recuperacao de carrinhos",
        kind: "Modelo de uplift operacional",
        target: "expected_recovered_revenue",
        metric: "Receita esperada",
        score: product_type_focus.sum { |row| row.fetch(:estimated_open_value) }.round(2),
        business_action: "Priorizar tipos de produto com maior valor agregado ainda em aberto."
      }
    ]
  end

  def linear_forecast(rows, value_key)
    points = rows.each_with_index.map do |row, index|
      {
        index: index,
        month: row.fetch("Mes"),
        actual: row.fetch(value_key).to_f
      }
    end

    slope, intercept = linear_regression(points.map { |row| row.fetch(:index) }, points.map { |row| row.fetch(:actual) })
    residuals = points.map { |row| row.fetch(:actual) - (intercept + slope * row.fetch(:index)) }
    residual_deviation = standard_deviation(residuals)
    last_month = Date.strptime("#{points.last.fetch(:month)}-01", "%Y-%m-%d")

    fitted = points.map do |row|
      {
        month: row.fetch(:month),
        actual: row.fetch(:actual).round(2),
        fitted: (intercept + slope * row.fetch(:index)).round(2)
      }
    end

    forecast = (1..FORECAST_HORIZON).map do |step|
      index = points.length - 1 + step
      prediction = [ intercept + slope * index, 0 ].max
      interval = residual_deviation * (1.15 + step * 0.08)

      {
        month: (last_month >> step).strftime("%Y-%m"),
        prediction: prediction.round(2),
        lower_bound: [ prediction - interval, 0 ].max.round(2),
        upper_bound: (prediction + interval).round(2)
      }
    end

    {
      algorithm: "Ordinary least squares over monthly index",
      target: value_key,
      training_points: points.length,
      trend_per_month: slope.round(2),
      history: fitted,
      forecast: forecast,
      metrics: regression_metrics(points, fitted),
      limitations: "Modelo demonstrativo, sem sazonalidade externa, promos ou variaveis macroeconomicas."
    }
  end

  def customer_scores(customers, period_end)
    max_orders = customers.map { |row| row.fetch("completed_orders").to_f }.max
    max_revenue = customers.map { |row| row.fetch("total_revenue").to_f }.max
    max_ticket = customers.map { |row| row.fetch("average_ticket").to_f }.max

    customers.map do |customer|
      last_purchase = Date.parse(customer.fetch("last_purchase"))
      recency_days = (period_end - last_purchase).to_i
      orders = customer.fetch("completed_orders").to_f
      revenue = customer.fetch("total_revenue").to_f
      ticket = customer.fetch("average_ticket").to_f
      lifetime_days = [ customer.fetch("customer_lifetime_days").to_f, 1 ].max
      frequency = orders / (lifetime_days / 30.0)

      order_score = safe_ratio(orders, max_orders)
      revenue_score = safe_ratio(revenue, max_revenue)
      ticket_score = safe_ratio(ticket, max_ticket)
      recency_score = 1.0 - [ recency_days / 180.0, 1.0 ].min
      frequency_score = [ frequency / 1.25, 1.0 ].min

      propensity = (
        order_score * 0.27 +
        revenue_score * 0.28 +
        ticket_score * 0.12 +
        recency_score * 0.23 +
        frequency_score * 0.10
      ) * 100

      churn_risk = (
        (1.0 - recency_score) * 0.52 +
        (1.0 - frequency_score) * 0.25 +
        (1.0 - order_score) * 0.13 +
        revenue_score * 0.10
      ) * 100

      {
        id: customer.fetch("id"),
        name: customer.fetch("name"),
        state: customer.fetch("state"),
        city: customer.fetch("city"),
        completed_orders: orders.to_i,
        total_revenue: revenue.round(2),
        average_ticket: ticket.round(2),
        days_since_last_purchase: recency_days,
        propensity_score: propensity.round(1),
        churn_risk_score: churn_risk.round(1),
        expected_90_day_value: (propensity / 100.0 * ticket * [ orders / 8.0, 1.0 ].min).round(2)
      }
    end.sort_by { |row| [ -row.fetch(:propensity_score), -row.fetch(:expected_90_day_value) ] }
  end

  def cart_recovery_scores(carts)
    carts.map do |cart|
      subtotal = cart.fetch("subtotal").to_f
      abandoned = cart.fetch("Status") == "abandoned"
      probability = (abandoned ? 0.24 : 0.36) + [ subtotal / 1_200.0, 0.12 ].min

      {
        id: cart.fetch("ID"),
        customer_name: cart.fetch("Nome"),
        state: cart.fetch("Estado"),
        city: cart.fetch("Cidade"),
        status: cart.fetch("Status"),
        item_count: cart.fetch("item_count"),
        units: cart.fetch("units"),
        subtotal: subtotal.round(2),
        recovery_probability: (probability * 100).round(1),
        expected_revenue: (subtotal * probability).round(2)
      }
    end.sort_by { |row| -row.fetch(:expected_revenue) }
  end

  def city_opportunities(scored_customers)
    scored_customers.group_by { |row| [ row.fetch(:city), row.fetch(:state) ] }.map do |(city, state), rows|
      expected_value = rows.sum { |row| row.fetch(:expected_90_day_value) }
      average_score = rows.sum { |row| row.fetch(:propensity_score) } / rows.length.to_f

      {
        city: city,
        state: state,
        customer_count: rows.length,
        average_propensity_score: average_score.round(1),
        expected_90_day_value: expected_value.round(2)
      }
    end.sort_by { |row| [ -row.fetch(:average_propensity_score), -row.fetch(:expected_90_day_value) ] }
  end

  def product_type_focus(carts, category_performance, product_ranking)
    open_carts = carts.select { |cart| cart.fetch("Status") == "open" }
    open_value_total = open_carts.sum { |cart| cart.fetch("subtotal").to_f }
    open_units_total = open_carts.sum { |cart| cart.fetch("units").to_f }
    revenue_total = category_performance.sum { |row| row.fetch("item_revenue").to_f }
    units_total = category_performance.sum { |row| row.fetch("units_sold").to_f }
    top_products_by_category = product_ranking.group_by { |row| row.fetch("Categoria") }

    category_performance.map do |category|
      item_revenue = category.fetch("item_revenue").to_f
      units_sold = category.fetch("units_sold").to_f
      revenue_share = safe_ratio(item_revenue, revenue_total)
      units_share = safe_ratio(units_sold, units_total)
      top_product = top_products_by_category.fetch(category.fetch("Categoria"), []).max_by { |row| row.fetch("item_revenue").to_f }

      {
        category: category.fetch("Categoria"),
        top_product: top_product&.fetch("Produto") || "Mix da categoria",
        estimated_open_value: (open_value_total * revenue_share).round(2),
        estimated_open_units: (open_units_total * units_share).round,
        historical_revenue: item_revenue.round(2)
      }
    end.sort_by { |row| [ -row.fetch(:estimated_open_value), -row.fetch(:estimated_open_units) ] }
  end

  def decision_notes(revenue_model, city_opportunities, product_type_focus)
    next_revenue = revenue_model.fetch(:forecast).first.fetch(:prediction)
    best_city = city_opportunities.first
    best_product_type = product_type_focus.first

    [
      "Proxima receita mensal estimada em R$ #{format('%.2f', next_revenue)} pelo modelo temporal.",
      "#{best_city.fetch(:city)} - #{best_city.fetch(:state)} concentra a maior propensao media da base: #{best_city.fetch(:average_propensity_score)}.",
      "#{best_product_type.fetch(:category).capitalize} lidera o foco de carrinhos abertos com valor estimado de R$ #{format('%.2f', best_product_type.fetch(:estimated_open_value))}.",
      "Os modelos foram escolhidos para explicabilidade e integracao em portfolio, nao para substituir treino offline robusto."
    ]
  end

  def linear_regression(xs, ys)
    mean_x = xs.sum.to_f / xs.length
    mean_y = ys.sum.to_f / ys.length
    numerator = xs.zip(ys).sum { |x, y| (x - mean_x) * (y - mean_y) }
    denominator = xs.sum { |x| (x - mean_x)**2 }
    slope = denominator.zero? ? 0.0 : numerator / denominator
    intercept = mean_y - slope * mean_x

    [ slope, intercept ]
  end

  def regression_metrics(points, fitted)
    actuals = points.map { |row| row.fetch(:actual) }
    predictions = fitted.map { |row| row.fetch(:fitted) }
    residuals = actuals.zip(predictions).map { |actual, prediction| actual - prediction }
    mean_actual = actuals.sum / actuals.length
    ss_res = residuals.sum { |value| value**2 }
    ss_tot = actuals.sum { |value| (value - mean_actual)**2 }
    mape_values = actuals.zip(predictions).filter_map do |actual, prediction|
      next if actual.zero?

      ((actual - prediction).abs / actual) * 100
    end

    {
      mae: (residuals.sum(&:abs) / residuals.length).round(2),
      mape_percent: (mape_values.sum / mape_values.length).round(2),
      r_squared: (ss_tot.zero? ? 0.0 : 1.0 - (ss_res / ss_tot)).round(3)
    }
  end

  def standard_deviation(values)
    return 0.0 if values.empty?

    mean = values.sum / values.length
    variance = values.sum { |value| (value - mean)**2 } / values.length
    Math.sqrt(variance)
  end

  def safe_ratio(value, max_value)
    return 0.0 if max_value.to_f.zero?

    [ value.to_f / max_value.to_f, 1.0 ].min
  end
end
