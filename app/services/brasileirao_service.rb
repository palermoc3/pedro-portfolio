class BrasileiraoService
  include HTTParty
  
  # API Football (plano grátis: 100 req/dia)
  # Brasileirão 2024 - League: 71
  base_uri "https://v3.football.api-sports.io"
  
  def initialize(api_key = ENV["API_FOOTBALL_KEY"])
    @api_key = api_key || "demo"
  end
  
  def standings
    fetch_standings
  rescue StandardError => e
    Rails.logger.error("BrasileiraoService error: #{e.message}")
    fallback_data
  end
  
  private
  
  def fetch_standings
    response = self.class.get(
      "/standings",
      query: {
        league: 71,        # Brasileirão
        season: 2024       # Temporada
      },
      headers: {
        "x-apisports-key": @api_key
      },
      timeout: 5
    )
    
    if response.success?
      parse_standings(response.parsed_response)
    else
      fallback_data
    end
  end
  
  def parse_standings(data)
    standings = data.dig("response", 0, "league", "standings", 0)
    
    return [] unless standings
    
    standings.map do |team|
      {
        position: team["rank"],
        team_name: team.dig("team", "name"),
        played: team["all"]["played"],
        wins: team["all"]["win"],
        draws: team["all"]["draw"],
        losses: team["all"]["lose"],
        goals_for: team["all"]["goals"]["for"],
        goals_against: team["all"]["goals"]["against"],
        goal_diff: team["goalsDiff"],
        points: team["points"]
      }
    end
  rescue => e
    Rails.logger.error("Parse error: #{e.message}")
    fallback_data
  end
  
  def fallback_data
    # Dados de fallback caso a API caia
    [
      { position: 1, team_name: "Palmeiras", played: 10, wins: 7, draws: 2, losses: 1, goals_for: 20, goals_against: 8, goal_diff: 12, points: 23 },
      { position: 2, team_name: "Botafogo", played: 10, wins: 6, draws: 2, losses: 2, goals_for: 18, goals_against: 10, goal_diff: 8, points: 20 },
      { position: 3, team_name: "Flamengo", played: 10, wins: 6, draws: 1, losses: 3, goals_for: 19, goals_against: 12, goal_diff: 7, points: 19 },
      { position: 4, team_name: "São Paulo", played: 10, wins: 5, draws: 2, losses: 3, goals_for: 16, goals_against: 14, goal_diff: 2, points: 17 },
      { position: 5, team_name: "Fortaleza", played: 10, wins: 5, draws: 1, losses: 4, goals_for: 15, goals_against: 13, goal_diff: 2, points: 16 }
    ]
  end
end
