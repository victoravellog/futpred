class Tournament < ApplicationRecord
  enum :format, { cup: 0, league: 1 }

  has_many :rounds, -> { order(position: :asc) }, dependent: :destroy
  has_many :tournament_teams, dependent: :destroy
  has_many :teams, through: :tournament_teams
  has_many :fixtures, through: :rounds
  has_many :organization_tournaments, dependent: :destroy
  has_many :organizations, through: :organization_tournaments
  has_many :tournament_notifications, dependent: :destroy
  has_many :standings, -> { order(position: :asc) }, dependent: :destroy

  validates :name, presence: true

  def starts_at
    fixtures.minimum(:kickoff_at)
  end

  def days_until_start
    return nil unless starts_at
    (starts_at.to_date - Date.current).to_i
  end

  def self.starting_in(days)
    target_date = days.days.from_now.to_date
    all.select { |t| t.starts_at&.to_date == target_date }
  end

  def self.starting_within(days)
    cutoff = days.days.from_now
    all.select { |t| t.starts_at.present? && t.starts_at > Time.current && t.starts_at <= cutoff }
  end

  def finished?
    fixtures.any? && fixtures.all?(&:finished?)
  end
end
