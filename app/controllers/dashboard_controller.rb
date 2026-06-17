class DashboardController < ApplicationController
  AGE_BUCKETS = {
    "18–24" => 18..24,
    "25–30" => 25..30,
    "31–40" => 31..40,
    "41+" => 41..Float::INFINITY
  }.freeze

  CLUB_COLORS = {
    "Athletico Paranaense" => "#EF4444",
    "Atlético Mineiro" => "#F1F5F9",
    "Bahia" => "#3B82F6",
    "Botafogo" => "#94A3B8",
    "Bragantino" => "#F1F5F9",
    "Ceará" => "#64748B",
    "Corinthians" => "#E5E7EB",
    "Cruzeiro" => "#2563EB",
    "Flamengo" => "#DC2626",
    "Fluminense" => "#10B981",
    "Fortaleza" => "#EF4444",
    "Grêmio" => "#06B6D4",
    "Internacional" => "#B91C1C",
    "Juventude" => "#22C55E",
    "Mirassol" => "#F59E0B",
    "Palmeiras" => "#16A34A",
    "Santos" => "#F8FAFC",
    "São Paulo" => "#EF4444",
    "Sport" => "#DC2626",
    "Vasco" => "#CBD5E1"
  }.freeze

  before_action :authenticate_user!

  def index
    # Quadrante a1 + b1: Tabela de usuários com paginação
    @recent_users = User.order(created_at: :desc).page(params[:page]).per(14)
    @total_users = User.count

# Quadrante a2: Gráfico Pizza - Distribuição de times
dados_originais = User.group(:club).count

# Ordena do maior para o menor e pega os 10 primeiros
top_10 = dados_originais.sort_by { |_key, value| -value }.first(10).to_h

# Calcula a soma de todo o restante que ficou de fora
total_outros = dados_originais.values.sum - top_10.values.sum

# Se houver itens fora do top 10, adiciona a categoria "Outros"
top_10["Outros"] = total_outros if total_outros > 0

@clubs_chart = top_10

    # Quadrante b2: Gráfico Barras - Faixa etária por time
    @age_chart = age_chart_by_club
    @age_chart_colors = @age_chart.map { |series| CLUB_COLORS.fetch(series[:name], "#6366F1") }

    # Quadrante c: Tabela API - Brasileirão
    brasileirao = BrasileiraoService.new
    @standings = brasileirao.standings
    @standings_source = brasileirao.source
    @current_user_standing = @standings.find { |team| team[:team_name] == current_user.club }
    @current_user_position_label = current_user_position_label
  end

  private

  def age_chart_by_club
    grouped_counts = Hash.new { |hash, club| hash[club] = AGE_BUCKETS.keys.index_with(0) }

    User.group(:club, :age).count.each do |(club, age), total|
      bucket = age_bucket_for(age)
      grouped_counts[club][bucket] += total if bucket
    end

    User::SERIE_A_CLUBS.filter_map do |club|
      data = grouped_counts[club]
      next if data.values.sum.zero?

      { name: club, data: data }
    end
  end

  def age_bucket_for(age)
    AGE_BUCKETS.find { |_label, range| range.cover?(age) }&.first
  end

  def current_user_position_label
    return "#{current_user.club}: não encontrado" if @current_user_standing.blank?

    "#{@current_user_standing[:team_name]}: #{@current_user_standing[:position]}º lugar"
  end
end
