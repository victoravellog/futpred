class SyncResults < Actor
  input :tournament

  output :updated_count

  def call
    self.updated_count = 0

    tournament.fixtures.where.not(status: :finished).find_each do |fixture|
      next unless fixture.external_id.present?

      match_data = client.match(fixture.external_id)
      update_fixture(fixture, match_data)
    end
  end

  private

  def client
    @client ||= FootballDataClient.new
  end

  def update_fixture(fixture, match_data)
    new_status = map_status(match_data["status"])
    score = match_data.dig("score", "fullTime")

    fixture.update!(
      status: new_status,
      home_score: score&.dig("home"),
      away_score: score&.dig("away")
    )

    if new_status == :finished && fixture.saved_change_to_status?
      calculate_predictions(fixture)
      self.updated_count += 1
    end
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
