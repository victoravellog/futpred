require 'rails_helper'

RSpec.describe Membership, type: :model do
  fixtures :all

  describe "validations" do
    it "prevents duplicate membership for same user and organization" do
      existing = memberships(:victor_liga_owner)
      duplicate = Membership.new(user: existing.user, organization: existing.organization)
      expect(duplicate).not_to be_valid
    end

    it "validates members limit for free organizations" do
      org = organizations(:liga_amigos)
      allow(org).to receive(:can_add_members?).and_return(false)

      membership = Membership.new(user: users(:victor), organization: org)
      allow(membership).to receive(:organization).and_return(org)

      expect(membership).not_to be_valid
      expect(membership.errors[:base]).to include(I18n.t('activerecord.errors.models.membership.members_limit_reached'))
    end

    it "allows membership when organization can add members" do
      org = organizations(:oficina)
      new_user = User.create!(email_address: "new@example.com", password: "password123", name: "New User")

      membership = Membership.new(user: new_user, organization: org)
      expect(membership).to be_valid
    end
  end
end
