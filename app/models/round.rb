class Round < ApplicationRecord
  belongs_to :tournament
  has_many :fixtures, -> { order(kickoff_at: :asc) }, dependent: :destroy

  validates :name, presence: true
  validates :scoring_multiplier, presence: true, numericality: { greater_than: 0 }

  before_validation :set_defaults

  def finished?
    fixtures.any? && fixtures.all?(&:finished?)
  end

  private

  def set_defaults
    self.scoring_multiplier ||= 1.0
  end
end
