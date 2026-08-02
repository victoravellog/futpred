class Standing < ApplicationRecord
  belongs_to :tournament
  belongs_to :team

  validates :tournament_id, uniqueness: { scope: :team_id }

  scope :ordered, -> { order(position: :asc) }
end
