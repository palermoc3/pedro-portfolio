require "net/http"
require "json"

class BrasileiraoService
  BASE_URI = "https://v3.football.api-sports.io"
  LEAGUE_ID = 71
  SEASON = 2026

  def initialize(api_key: ENV["API_FOOTBALL_KEY"])
    @api_key = api_key
    @source = "API-Football #{SEASON}"
  end

  def standings
    return fallback_data if @api_key.blank?

    apifootball_standings
  rescue StandardError => e
    Rails.logger.error("BrasileiraoService error: #{e.class.name} #{e.message}")
    fallback_data
  end

  def source
    @source
  end

  private

  def apifootball_standings
    uri = URI("#{BASE_URI}/standings")
    uri.query = URI.encode_www_form(league: LEAGUE_ID, season: SEASON)

    request = Net::HTTP::Get.new(uri)
    request["x-apisports-key"] = @api_key

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, read_timeout: 5, open_timeout: 5) do |http|
      http.request(request)
    end

    if response.is_a?(Net::HTTPSuccess)
      parse_football(JSON.parse(response.body))
    else
      Rails.logger.warn("BrasileiraoService API-Football failed: #{response.code} #{response.message}")
      fallback_data
    end
  rescue StandardError => e
    Rails.logger.error("BrasileiraoService API-Football connection error: #{e.class.name} #{e.message}")
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

  def fallback_data
    [
      { position: 1, team_name: "Palmeiras", played: 10, wins: 7, draws: 2, losses: 1, goals_for: 20, goals_against: 8, goal_diff: 12, points: 23 },
      { position: 2, team_name: "Botafogo", played: 10, wins: 6, draws: 2, losses: 2, goals_for: 18, goals_against: 10, goal_diff: 8, points: 20 },
      { position: 3, team_name: "Flamengo", played: 10, wins: 6, draws: 1, losses: 3, goals_for: 19, goals_against: 12, goal_diff: 7, points: 19 },
      { position: 4, team_name: "São Paulo", played: 10, wins: 5, draws: 2, losses: 3, goals_for: 16, goals_against: 14, goal_diff: 2, points: 17 },
      { position: 5, team_name: "Fortaleza", played: 10, wins: 5, draws: 1, losses: 4, goals_for: 15, goals_against: 13, goal_diff: 2, points: 16 },
      { position: 6, team_name: "Bahia", played: 10, wins: 4, draws: 4, losses: 2, goals_for: 14, goals_against: 11, goal_diff: 3, points: 16 },
      { position: 7, team_name: "Cruzeiro", played: 10, wins: 4, draws: 3, losses: 3, goals_for: 13, goals_against: 10, goal_diff: 3, points: 15 },
      { position: 8, team_name: "Atlético Mineiro", played: 10, wins: 4, draws: 3, losses: 3, goals_for: 12, goals_against: 11, goal_diff: 1, points: 15 },
      { position: 9, team_name: "Fluminense", played: 10, wins: 4, draws: 2, losses: 4, goals_for: 12, goals_against: 12, goal_diff: 0, points: 14 },
      { position: 10, team_name: "Bragantino", played: 10, wins: 3, draws: 4, losses: 3, goals_for: 11, goals_against: 11, goal_diff: 0, points: 13 },
      { position: 11, team_name: "Corinthians", played: 10, wins: 3, draws: 3, losses: 4, goals_for: 10, goals_against: 12, goal_diff: -2, points: 12 },
      { position: 12, team_name: "Internacional", played: 10, wins: 3, draws: 3, losses: 4, goals_for: 9, goals_against: 11, goal_diff: -2, points: 12 },
      { position: 13, team_name: "Grêmio", played: 10, wins: 3, draws: 2, losses: 5, goals_for: 12, goals_against: 15, goal_diff: -3, points: 11 },
      { position: 14, team_name: "Vasco", played: 10, wins: 3, draws: 2, losses: 5, goals_for: 11, goals_against: 15, goal_diff: -4, points: 11 },
      { position: 15, team_name: "Santos", played: 10, wins: 2, draws: 4, losses: 4, goals_for: 10, goals_against: 13, goal_diff: -3, points: 10 },
      { position: 16, team_name: "Ceará", played: 10, wins: 2, draws: 4, losses: 4, goals_for: 9, goals_against: 12, goal_diff: -3, points: 10 },
      { position: 17, team_name: "Sport", played: 10, wins: 2, draws: 3, losses: 5, goals_for: 8, goals_against: 13, goal_diff: -5, points: 9 },
      { position: 18, team_name: "Juventude", played: 10, wins: 2, draws: 2, losses: 6, goals_for: 8, goals_against: 15, goal_diff: -7, points: 8 },
      { position: 19, team_name: "Mirassol", played: 10, wins: 1, draws: 4, losses: 5, goals_for: 7, goals_against: 14, goal_diff: -7, points: 7 },
      { position: 20, team_name: "Athletico Paranaense", played: 10, wins: 1, draws: 3, losses: 6, goals_for: 7, goals_against: 17, goal_diff: -10, points: 6 }
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
