require "test_helper"

class DashboardApiTest < ActionDispatch::IntegrationTest
  test "serves the public KPI payload" do
    get "/kpis.json"

    assert_response :success

    payload = JSON.parse(response.body)
    assert_includes payload.keys, "receita"
    assert_includes payload.keys, "sales"
    assert_equal ["Jul 2024", "Jan 2025", "Jul 2025", "Jan 2026", "Jul 2026"], payload["sales"]["months"]
  end

  test "serves paginated customers payload for Kaminari consumption" do
    get "/api/customers", params: { page: 1 }

    assert_response :success

    payload = JSON.parse(response.body)
    pagination = payload.fetch("pagination")
    customers = payload.fetch("customers")

    assert_equal 1, pagination.fetch("current_page")
    assert_equal 20, pagination.fetch("per_page")
    assert_equal 9, pagination.fetch("total_pages")
    assert_equal 180, pagination.fetch("total_count")
    assert_equal 2, pagination.fetch("next_page")
    assert_nil pagination.fetch("prev_page")
    assert_equal 20, customers.length

    expected_customer_keys = %w[
      id name email state city age completed_orders total_revenue average_ticket
      first_purchase last_purchase repeat_customer revenue_rank orders_rank
      customer_lifetime_days share_of_revenue_percent
    ]
    assert_equal expected_customer_keys.sort, customers.first.keys.sort
  end

  test "serves customers with custom per page using Kaminari" do
    get "/api/customers", params: { page: 2, per_page: 50 }

    assert_response :success

    payload = JSON.parse(response.body)
    pagination = payload.fetch("pagination")

    assert_equal 2, pagination.fetch("current_page")
    assert_equal 50, pagination.fetch("per_page")
    assert_equal 4, pagination.fetch("total_pages")
    assert_equal 180, pagination.fetch("total_count")
    assert_equal 3, pagination.fetch("next_page")
    assert_equal 1, pagination.fetch("prev_page")
    assert_equal 50, payload.fetch("customers").length
  end

  test "customers static payload includes dashboard and governance contract" do
    payload = JSON.parse(Rails.root.join("public/customers_kaminari.json").read)

    assert_equal "rails_dashboard", payload.fetch("resource")
    assert_equal 180, payload.fetch("total_count")
    assert_equal 20, payload.fetch("per_page")
    assert_equal 9, payload.fetch("total_pages")
    assert_equal 180, payload.fetch("customers").length
    assert_equal 9, payload.fetch("pages").length
    assert_equal 20, payload.fetch("pages").first.fetch("customers").length

    %w[metadata kpis metric_contract ui_schema insights report_export ai_qa].each do |key|
      assert_includes payload.keys, key
    end

    charts = payload.fetch("charts")
    %w[
      monthly_customer_revenue customer_cohorts revenue_by_state top_customers
      orders_distribution revenue_distribution monthly_gross_profit
      payment_method_summary shipping_discount_trend
    ].each do |key|
      assert_includes charts.keys, key
      assert_not_empty charts.fetch(key)
    end

    tables = payload.fetch("tables")
    %w[
      category_performance product_ranking cart_status_summary rating_distribution
      product_review_table cart_recovery_table business_questions
    ].each do |key|
      assert_includes tables.keys, key
      assert_not_empty tables.fetch(key)
    end

    assert_equal 160692.02, payload.dig("kpis", "revenue", "order_revenue")
    assert_equal 2127, payload.dig("kpis", "operation", "completed_orders")
    assert_includes payload.fetch("metric_contract").first.fetch("calculation"), "Deduplicate by ID Venda"
  end

  test "dashboard renders public store KPI integration without login" do
    get "/dashboard"

    assert_response :success
    assert_select "h1", text: "Dashboard da loja"
    assert_select "h2", text: "Dados governados, payload estático e consumo Rails"
    assert_select "h2", text: "Receita mensal"
    assert_select "[data-kpi-primary-grid].store-kpi-grid", 1
    assert_select "[data-kpi-secondary-grid].store-metrics-grid", 1
    assert_select ".mei-kpi-card__label", text: "Receita de pedidos"
    assert_select "#sales-chart", 1
    assert_includes response.body, "renderSvgChart"
    assert_includes response.body, "dataset_analitico_mei.xlsx"
    assert_includes response.body, "customers_kaminari.json"
    assert_includes response.body, "/api/customers"
    assert_includes response.body, "https://palermoc3.github.io/mei-commerce-analytics-dashboard/public/kpis.json"
    refute_includes response.body, "Gráfico indisponível"
    refute_includes response.body, "Usuários Cadastrados"
    refute_includes response.body, "Classificação"
    refute_includes response.body, "Time do usuário"
    refute_includes response.body, "Entrar"
    refute_includes response.body, "Sair"
    refute_includes response.body, "login"
  end

  test "authentication routes are not mounted" do
    get "/users/sign_in"

    assert_response :not_found
  end
end
