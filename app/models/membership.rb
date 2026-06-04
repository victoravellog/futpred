class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  enum :role, { member: 0, admin: 1, owner: 2 }

  validates :user_id, uniqueness: { scope: :organization_id }
  validate :organization_members_limit, on: :create

  private

  def organization_members_limit
    return unless organization&.free?
    return if organization.can_add_members?

    errors.add(:base, :members_limit_reached)
  end
end
