require "net/http"
require "json"

class FootballDataClient
  BASE_URL = "https://api.football-data.org/v4"

  def initialize(api_key: Rails.application.credentials.football_data_api_key)
    @api_key = api_key
  end

  def competitions
    get("/competitions")["competitions"]
  end

  def competition(code)
    get("/competitions/#{code}")
  end

  def teams(competition_code)
    get("/competitions/#{competition_code}/teams")["teams"]
  end

  def matches(competition_code, season: nil, matchday: nil)
    params = {}
    params[:season] = season if season
    params[:matchday] = matchday if matchday
    get("/competitions/#{competition_code}/matches", params)["matches"]
  end

  def match(match_id)
    get("/matches/#{match_id}")
  end

  def standings(competition_code, season: nil)
    params = {}
    params[:season] = season if season
    data = get("/competitions/#{competition_code}/standings", params)
    data["standings"]&.first&.dig("table") || []
  end

  def current_season(competition_code)
    data = competition(competition_code)
    start_date = data.dig("currentSeason", "startDate")
    start_date ? Date.parse(start_date).year : nil
  end

  private

  def get(path, params = {})
    uri = URI("#{BASE_URL}#{path}")
    uri.query = URI.encode_www_form(params) if params.any?

    request = Net::HTTP::Get.new(uri)
    request["X-Auth-Token"] = @api_key

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    raise ApiError, "#{response.code}: #{response.body}" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  end

  class ApiError < StandardError; end
end
