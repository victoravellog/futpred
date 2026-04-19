class Tournament < ApplicationRecord
  has_many :rounds, -> { order(position: :asc) }, dependent: :destroy
  has_many :tournament_teams, dependent: :destroy
  has_many :teams, through: :tournament_teams
  has_many :fixtures, through: :rounds
  has_many :organization_tournaments, dependent: :destroy
  has_many :organizations, through: :organization_tournaments

  validates :name, presence: true
end
