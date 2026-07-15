class KpisController < ApplicationController
  def show
    payload = {
      receita: {
        revenue: 7800,
        item_revenue: 7200,
        average_ticket: 260
      },
      rentabilidade: {
        gross_profit: 5200,
        gross_margin_percent: 66.7
      },
      operacao: {
        completed_orders: 30,
        units_sold: 120,
        products_active: 18,
        open_carts: 7,
        abandoned_carts: 3
      },
      clientes: {
        average_rating: 4.8,
        open_carts: 7,
        abandoned_carts: 3,
        cart_value: 1450
      },
      sales: {
        months: [ "Jul 2024", "Jan 2025", "Jul 2025", "Jan 2026", "Jul 2026" ],
        values: [ 6500, 7200, 6880, 7650, 7800 ]
      }
    }

    render json: payload
  end
end
