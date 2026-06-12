class SyncResults < Actor
  input :tournament

  output :updated_count

  def call
    self.updated_count = 0

    matches_by_external_id = fetch_all_matches
    if matches_by_external_id.empty?
      Rails.logger.warn("SyncResults: No matches fetched for #{tournament.name}")
      return
    end

    Rails.logger.info("SyncResults: Processing #{pending_fixtures.count} pending fixtures for #{tournament.name}")

    pending_fixtures.find_each do |fixture|
      match_data = matches_by_external_id[fixture.external_id]
      unless match_data
        Rails.logger.warn("SyncResults: No API data for fixture #{fixture.id} (external_id: #{fixture.external_id})")
        next
      end

      sync_fixture(fixture, match_data)
    end

    Rails.logger.info("SyncResults: Completed for #{tournament.name}, #{updated_count} fixtures finished")
  end

  private

  def client
    @client ||= FootballDataClient.new
  end

  def pending_fixtures
    tournament.fixtures.where.not(status: :finished).where.not(external_id: nil)
  end

  def fetch_all_matches
    competition_code = tournament.external_id
    return {} unless competition_code

    matches = client.matches(competition_code)
    matches.index_by { |m| m["id"].to_s }
  rescue FootballDataClient::ApiError => e
    Rails.logger.error("SyncResults API error for #{tournament.name}: #{e.message}")
    {}
  end

  def sync_fixture(fixture, match_data)
    new_status = map_status(match_data["status"])
    score = match_data.dig("score", "fullTime")

    fixture.update!(
      status: new_status,
      home_score: score&.dig("home"),
      away_score: score&.dig("away")
    )

    if new_status == :finished && fixture.saved_change_to_status?
      Rails.logger.info("SyncResults: Fixture #{fixture.id} finished - calculating predictions")
      calculate_predictions(fixture)
      self.updated_count += 1
    end
  rescue StandardError => e
    Rails.logger.error("SyncResults: Error updating fixture #{fixture.id}: #{e.message}")
  end

  def calculate_predictions(fixture)
    fixture.predictions.find_each do |prediction|
      CalculatePredictionScore.call(prediction: prediction)
    end
  end

  def map_status(api_status)
    case api_status
    when "SCHEDULED", "TIMED" then :scheduled
    when "IN_PLAY", "PAUSED", "LIVE" then :live
    when "FINISHED" then :finished
    when "POSTPONED", "CANCELLED" then :cancelled
    else :scheduled
    end
  end
end
