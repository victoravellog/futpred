require 'rails_helper'

RSpec.describe Organization, type: :model do
  fixtures :all

  describe "#members_limit" do
    it "returns 20 for free plan" do
      org = organizations(:liga_amigos)
      expect(org.members_limit).to eq(20)
    end

    it "returns infinity for pro plan" do
      org = organizations(:liga_amigos)
      org.plan = :pro
      expect(org.members_limit).to eq(Float::INFINITY)
    end

    it "returns infinity for enterprise plan" do
      org = organizations(:liga_amigos)
      org.plan = :enterprise
      expect(org.members_limit).to eq(Float::INFINITY)
    end
  end

  describe "#can_add_members?" do
    it "returns true when under limit" do
      org = organizations(:liga_amigos)
      expect(org.can_add_members?).to be true
    end

    it "returns false when at limit for free plan" do
      org = organizations(:liga_amigos)
      allow(org.memberships).to receive(:count).and_return(20)
      expect(org.can_add_members?).to be false
    end

    it "returns true when at limit for paid plan" do
      org = organizations(:liga_amigos)
      org.plan = :pro
      allow(org.memberships).to receive(:count).and_return(100)
      expect(org.can_add_members?).to be true
    end
  end
end
