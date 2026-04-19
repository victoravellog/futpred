class Team < ApplicationRecord
  has_many :tournament_teams, dependent: :destroy
  has_many :tournaments, through: :tournament_teams
  has_many :home_fixtures, class_name: "Fixture", foreign_key: :home_team_id, dependent: :destroy
  has_many :away_fixtures, class_name: "Fixture", foreign_key: :away_team_id, dependent: :destroy

  validates :name, presence: true

  def display_name
    TeamNames.translate(name)
  end
end
