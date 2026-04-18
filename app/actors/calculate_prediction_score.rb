class CalculatePredictionScore < Actor
  input :prediction

  output :points

  POINTS_EXACT_SCORE = 5
  POINTS_CORRECT_RESULT = 3

  def call
    return self.points = 0 unless fixture.finished?
    return self.points = 0 if already_calculated?

    base_points = calculate_base_points
    self.points = (base_points * multiplier).round

    prediction.update!(points_earned: points)
  end

  private

  def fixture
    prediction.fixture
  end

  def multiplier
    fixture.round.scoring_multiplier
  end

  def already_calculated?
    prediction.points_earned.present?
  end

  def calculate_base_points
    if exact_score?
      POINTS_EXACT_SCORE
    elsif correct_result?
      POINTS_CORRECT_RESULT
    else
      0
    end
  end

  def exact_score?
    prediction.predicted_home_score == fixture.home_score &&
      prediction.predicted_away_score == fixture.away_score
  end

  def correct_result?
    prediction.predicted_result == fixture.result
  end
end
