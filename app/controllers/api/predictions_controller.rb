module Api
  class PredictionsController < ApplicationController
    def show
      render json: PredictionPortfolioService.new.call
    end
  end
end
