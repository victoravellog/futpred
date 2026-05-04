require 'rails_helper'

RSpec.describe TournamentTeam, type: :model do
  fixtures :all

  describe "associations" do
    it "belongs to tournament" do
      tt = tournament_teams(:copa_argentina)
      expect(tt.tournament).to eq(tournaments(:copa_america))
    end

    it "belongs to team" do
      tt = tournament_teams(:copa_argentina)
      expect(tt.team).to eq(teams(:argentina))
    end
  end
end
