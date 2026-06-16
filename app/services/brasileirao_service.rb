class BrasileiraoService
  include HTTParty

  BASE_URI = "https://v3.football.api-sports.io"
  BRASILIO_BASE_URI = "https://brasil.io/api"

  base_uri BASE_URI

  def initialize(api_key: ENV["API_FOOTBALL_KEY"], brasilio_token: ENV["BRASIL_IO_TOKEN"])
    @api_key = api_key
    @brasilio_token = brasilio_token
    @source = "fallback"
  end

  def standings
    if @brasilio_token.present?
      brasilio_standings
    elsif @api_key.present?
      apifootball_standings
    else
      Rails.logger.info("BrasileiraoService: nenhum token configurado, usando fallback")
      fallback_data
    end
  rescue StandardError => e
    Rails.logger.error("BrasileiraoService error: #{e.class.name} #{e.message}")
    fallback_data
  end

  def source
    @source
  end

  private

  def apifootball_standings
    response = self.class.get(
      "/standings",
      query: {
        league: 71,
        season: 2026
      },
      headers: {
        "x-apisports-key" => @api_key
      },
      timeout: 5
    )

    if response.success?
      @source = "API-Football"
      parse_football(response.parsed_response)
    else
      Rails.logger.warn("BrasileiraoService API-Football failed: #{response.code} #{response.message}")
      fallback_data
    end
  rescue StandardError => e
    Rails.logger.error("BrasileiraoService API-Football connection error: #{e.class.name} #{e.message}")
    fallback_data
  end

  def brasilio_standings
    response = HTTParty.get(
      "#{BRASILIO_BASE_URI}/dataset/campeonato-brasileiro/series-historicas/data/",
      headers: {
        "Authorization" => "Token #{@brasilio_token}"
      },
      query: {
        format: "json",
        page_size: 20
      },
      timeout: 5
    )

    if response.success?
      @source = "Brasil.io"
      parse_brasilio(response.parsed_response)
    else
      Rails.logger.warn("BrasileiraoService Brasil.io failed: #{response.code} #{response.message}")
      fallback_data
    end
  rescue StandardError => e
    Rails.logger.error("BrasileiraoService Brasil.io connection error: #{e.class.name} #{e.message}")
    fallback_data
  end

  def parse_football(data)
    standings = data.dig("response", 0, "league", "standings", 0)
    return fallback_data unless standings.is_a?(Array)

    Rails.logger.info("BrasileiraoService: parsing #{standings.length} teams from API-Football")
    standings.map do |team|
      api_name = team.dig("team", "name") || "Unknown"
      {
        position: team["rank"],
        team_name: normalize_team_name(api_name),
        played: team.dig("all", "played") || 0,
        wins: team.dig("all", "win") || 0,
        draws: team.dig("all", "draw") || 0,
        losses: team.dig("all", "lose") || 0,
        goals_for: team.dig("all", "goals", "for") || 0,
        goals_against: team.dig("all", "goals", "against") || 0,
        goal_diff: team["goalsDiff"] || 0,
        points: team["points"] || 0
      }
    end
  rescue StandardError => e
    Rails.logger.error("BrasileiraoService parse error: #{e.class.name} #{e.message}")
    fallback_data
  end

  def parse_brasilio(data)
    rows = data["results"]
    return fallback_data unless rows.is_a?(Array)

    Rails.logger.info("BrasileiraoService: parsing #{rows.length} teams from Brasil.io")
    rows.map do |row|
      api_name = row["team"] || row["clube"] || row["team_name"] || "Time desconhecido"
      {
        position: row["pos"] || row["position"] || 0,
        team_name: normalize_team_name(api_name),
        played: row["games"] || row["played"] || 0,
        wins: row["wins"] || row["vitoria"] || 0,
        draws: row["draws"] || row["empates"] || 0,
        losses: row["losses"] || row["derrotas"] || 0,
        goals_for: row["goals_scored"] || row["goals_for"] || 0,
        goals_against: row["goals_conceded"] || row["goals_against"] || 0,
        goal_diff: row["goal_difference"] || row["goals_diff"] || 0,
        points: row["points"] || row["pontuacao"] || 0
      }
    end
  rescue StandardError => e
    Rails.logger.error("BrasileiraoService.parse_brasilio error: #{e.class.name} #{e.message}")
    fallback_data
  end

  def fallback_data
    [
      { position: 1, team_name: "Palmeiras", played: 10, wins: 7, draws: 2, losses: 1, goals_for: 20, goals_against: 8, goal_diff: 12, points: 23 },
      { position: 2, team_name: "Botafogo", played: 10, wins: 6, draws: 2, losses: 2, goals_for: 18, goals_against: 10, goal_diff: 8, points: 20 },
      { position: 3, team_name: "Flamengo", played: 10, wins: 6, draws: 1, losses: 3, goals_for: 19, goals_against: 12, goal_diff: 7, points: 19 },
      { position: 4, team_name: "São Paulo", played: 10, wins: 5, draws: 2, losses: 3, goals_for: 16, goals_against: 14, goal_diff: 2, points: 17 },
      { position: 5, team_name: "Fortaleza", played: 10, wins: 5, draws: 1, losses: 4, goals_for: 15, goals_against: 13, goal_diff: 2, points: 16 }
    ]
  end

  def normalize_team_name(api_name)
    return api_name if api_name.blank?

    # Transliterate, downcase, strip
    normalized_api = I18n.transliterate(api_name.to_s).downcase.strip

    # Busca fuzzy: encontra o clube canônico mais similar
    canonical_clubs = User::SERIE_A_CLUBS
    best_match = canonical_clubs.find do |club|
      normalized_canonical = I18n.transliterate(club).downcase.strip
      # Match exato ou contém um no outro
      normalized_api == normalized_canonical || 
        normalized_api.include?(normalized_canonical) || 
        normalized_canonical.include?(normalized_api)
    end

    best_match || api_name # Fallback ao nome original se nenhum match
  end
end
