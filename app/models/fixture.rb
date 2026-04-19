class Fixture < ApplicationRecord
  belongs_to :round
  belongs_to :home_team, class_name: "Team"
  belongs_to :away_team, class_name: "Team"
  has_many :predictions, dependent: :destroy

  enum :status, { scheduled: 0, live: 1, finished: 2, cancelled: 3 }

  validates :kickoff_at, presence: true

  after_update :process_results, if: :just_finished?

  def finished?
    status == "finished" && home_score.present? && away_score.present?
  end

  def predictable?
    scheduled? && kickoff_at > Time.current
  end

  def result
    return nil unless finished?
    if home_score > away_score
      :home_win
    elsif away_score > home_score
      :away_win
    else
      :draw
    end
  end

  private

  def just_finished?
    saved_change_to_status? && finished?
  end

  def process_results
    ProcessFixtureResultsJob.perform_later(id)
  end
end
