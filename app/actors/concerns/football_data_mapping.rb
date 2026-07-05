module FootballDataMapping
  extend ActiveSupport::Concern

  private

  def extract_scores(match_data)
    score_data = match_data["score"]
    return { home: nil, away: nil, home_penalty: nil, away_penalty: nil } unless score_data

    penalties = score_data["penalties"]

    if penalties && penalties["home"].present?
      regular = score_data["regularTime"] || {}
      extra = score_data["extraTime"] || {}

      {
        home: (regular["home"] || 0) + (extra["home"] || 0),
        away: (regular["away"] || 0) + (extra["away"] || 0),
        home_penalty: penalties["home"],
        away_penalty: penalties["away"]
      }
    else
      full_time = score_data["fullTime"] || {}

      {
        home: full_time["home"],
        away: full_time["away"],
        home_penalty: nil,
        away_penalty: nil
      }
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
