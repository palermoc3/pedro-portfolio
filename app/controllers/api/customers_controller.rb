module Api
  class CustomersController < ApplicationController
    PAYLOAD_PATH = Rails.root.join("public/customers_kaminari.json")
    DEFAULT_PER_PAGE = 20
    MAX_PER_PAGE = 100

    def index
      payload = JSON.parse(PAYLOAD_PATH.read)
      page = positive_integer(params[:page], 1)
      per_page = positive_integer(params[:per_page], payload.fetch("per_page", DEFAULT_PER_PAGE))

      per_page = [ per_page, MAX_PER_PAGE ].min

      render json: page_payload(payload, page, per_page)
    end

    private

    def page_payload(payload, page, per_page)
      if per_page == payload.fetch("per_page") && payload["pages"].present?
        existing_page = payload.fetch("pages").find do |entry|
          entry.dig("pagination", "current_page") == page
        end

        return existing_page if existing_page.present?
      end

      customers = payload.fetch("customers")
      paginated = Kaminari
        .paginate_array(customers, total_count: customers.length)
        .page(page)
        .per(per_page)

      {
        pagination: {
          current_page: paginated.current_page,
          per_page: paginated.limit_value,
          total_pages: paginated.total_pages,
          total_count: paginated.total_count,
          next_page: paginated.next_page,
          prev_page: paginated.prev_page
        },
        customers: paginated
      }
    end

    def positive_integer(value, fallback)
      parsed = value.to_i
      parsed.positive? ? parsed : fallback
    end
  end
end
