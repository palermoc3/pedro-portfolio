class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    # Quadrante a1 + b1: Tabela de usuários com paginação
    @recent_users = User.order(created_at: :desc).page(params[:page]).per(10)
    @total_users = User.count

    # Quadrante a2: Gráfico Pizza - Distribuição de times
    @clubs_chart = User.group(:club).count

    # Quadrante b2: Gráfico Barras - Faixa etária
    @age_chart = {
      "18–24" => User.where(age: 18..24).count,
      "25–30" => User.where(age: 25..30).count,
      "31–40" => User.where(age: 31..40).count,
      "41+"   => User.where("age > 40").count
    }
    
    # Quadrante c: Tabela API - Brasileirão
    brasileirao = BrasileiraoService.new
    @standings = brasileirao.standings.first(10) # Top 10 times
  end
end
