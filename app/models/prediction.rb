class Prediction < ApplicationRecord
  belongs_to :user
  belongs_to :fixture
  belongs_to :organization_tournament

  validates :predicted_home_score, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :predicted_away_score, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :user_id, uniqueness: { scope: [ :fixture_id, :organization_tournament_id ] }
  validate :fixture_must_be_predictable, on: :create

  def predicted_result
    if predicted_home_score > predicted_away_score
      :home_win
    elsif predicted_away_score > predicted_home_score
      :away_win
    else
      :draw
    end
  end

  def exact_score?
    fixture.finished? &&
      predicted_home_score == fixture.home_score &&
      predicted_away_score == fixture.away_score
  end

  def correct_result?
    fixture.finished? && predicted_result == fixture.result
  end

  private

  def fixture_must_be_predictable
    return if fixture.nil?
    errors.add(:fixture, "ya no acepta predicciones") unless fixture.predictable?
  end
end
