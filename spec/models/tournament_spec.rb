require 'rails_helper'

RSpec.describe Tournament, type: :model do
  fixtures :all

  describe "validations" do
    it "requires name" do
      tournament = Tournament.new(name: nil)
      expect(tournament).not_to be_valid
      expect(tournament.errors[:name]).to be_present
    end
  end

  describe "associations" do
    it "has many rounds" do
      tournament = tournaments(:copa_america)
      expect(tournament.rounds).to be_present
    end

    it "has many fixtures through rounds" do
      tournament = tournaments(:copa_america)
      expect(tournament.fixtures).to be_present
    end

    it "has many teams through tournament_teams" do
      tournament = tournaments(:copa_america)
      expect(tournament.teams).to be_present
    end
  end
end
