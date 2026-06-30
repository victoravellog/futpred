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
    tournament.fixtures
      .where.not(external_id: nil)
      .where("status != ? OR home_score IS NULL OR away_score IS NULL", Fixture.statuses[:finished])
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
    api_status = match_data["status"]
    scores = extract_scores(match_data)

    # Don't mark as finished if score is missing
    new_status = if api_status == "FINISHED" && (scores[:home].nil? || scores[:away].nil?)
      Rails.logger.warn("SyncResults: Fixture #{fixture.id} is FINISHED but score is missing, keeping as live")
      :live
    else
      map_status(api_status)
    end

    fixture.update!(
      status: new_status,
      home_score: scores[:home],
      away_score: scores[:away],
      home_penalty_score: scores[:home_penalty],
      away_penalty_score: scores[:away_penalty]
    )

    if new_status == :finished && fixture.saved_change_to_status?
      Rails.logger.info("SyncResults: Fixture #{fixture.id} finished (#{home_score}-#{away_score}) - calculating predictions")
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

  def extract_scores(match_data)
    score_data = match_data["score"]
    penalties = score_data&.dig("penalties")

    if penalties && penalties["home"].present?
      # Match went to penalties - use regularTime + extraTime for prediction scoring
      regular = score_data.dig("regularTime") || {}
      extra = score_data.dig("extraTime") || {}

      {
        home: (regular["home"] || 0) + (extra["home"] || 0),
        away: (regular["away"] || 0) + (extra["away"] || 0),
        home_penalty: penalties["home"],
        away_penalty: penalties["away"]
      }
    else
      # Normal match - use fullTime
      full_time = score_data&.dig("fullTime") || {}

      {
        home: full_time["home"],
        away: full_time["away"],
        home_penalty: nil,
        away_penalty: nil
      }
    end
  end
end
