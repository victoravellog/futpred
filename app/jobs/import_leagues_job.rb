class ImportLeaguesJob < ApplicationJob
  queue_as :default

  LEAGUES = {
    "PL" => "Premier League",
    "PD" => "La Liga",
    "BL1" => "Bundesliga",
    "SA" => "Serie A",
    "FL1" => "Ligue 1"
  }.freeze

  def perform(league_codes = LEAGUES.keys)
    league_codes.each_with_index do |code, index|
      if index > 0
        Rails.logger.info("ImportLeaguesJob: Waiting 60s to avoid rate limit...")
        sleep(60)
      end

      import_league(code)
    end

    Rails.logger.info("ImportLeaguesJob: Completed. #{league_codes.size} leagues processed.")
  end

  private

  def import_league(code)
    name = LEAGUES[code] || code
    Rails.logger.info("ImportLeaguesJob: Importing #{name} (#{code})...")

    result = ImportCompetition.call(competition_code: code)

    if result.success?
      tournament = result.tournament
      Rails.logger.info("ImportLeaguesJob: #{tournament.name} - #{tournament.rounds.count} rounds, #{tournament.fixtures.count} fixtures")
    else
      Rails.logger.error("ImportLeaguesJob: Error importing #{name}: #{result.failure}")
    end
  rescue FootballDataClient::ApiError => e
    handle_rate_limit(code, name, e)
  rescue StandardError => e
    Rails.logger.error("ImportLeaguesJob: Error importing #{name}: #{e.message}")
  end

  def handle_rate_limit(code, name, error)
    if error.message.include?("429")
      wait_time = error.message.match(/Wait (\d+) seconds/)&.[](1)&.to_i || 60
      Rails.logger.warn("ImportLeaguesJob: Rate limited on #{name}. Waiting #{wait_time}s...")
      sleep(wait_time + 5)
      import_league(code)
    else
      Rails.logger.error("ImportLeaguesJob: API error for #{name}: #{error.message}")
    end
  end
end
