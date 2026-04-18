class Tournament < ApplicationRecord
  belongs_to :organization
  has_many :rounds, -> { order(position: :asc) }, dependent: :destroy
  has_many :tournament_teams, dependent: :destroy
  has_many :teams, through: :tournament_teams
  has_many :fixtures, through: :rounds

  validates :name, presence: true
end
