class OrganizationTournament < ApplicationRecord
  belongs_to :organization
  belongs_to :tournament

  has_many :predictions, dependent: :destroy

  validates :tournament_id, uniqueness: { scope: :organization_id }
end
