require 'rails_helper'

RSpec.describe Team, type: :model do
  fixtures :all

  describe "validations" do
    it "requires name" do
      team = Team.new(name: nil)
      expect(team).not_to be_valid
      expect(team.errors[:name]).to be_present
    end
  end

  describe "#display_name" do
    it "returns translated name" do
      team = teams(:argentina)
      expect(team.display_name).to be_present
    end
  end

  describe "associations" do
    it "has many home_fixtures" do
      team = teams(:argentina)
      expect(team.home_fixtures).to be_present
    end

    it "has many away_fixtures" do
      team = teams(:brasil)
      expect(team.away_fixtures).to be_present
    end
  end
end
