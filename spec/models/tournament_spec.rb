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

  describe "#starts_at" do
    it "returns the earliest fixture kickoff time" do
      tournament = tournaments(:copa_america)
      earliest_fixture = tournament.fixtures.order(:kickoff_at).first
      expect(tournament.starts_at).to eq(earliest_fixture.kickoff_at)
    end

    it "returns nil when there are no fixtures" do
      tournament = Tournament.create!(name: "Empty Tournament")
      expect(tournament.starts_at).to be_nil
    end
  end

  describe "#days_until_start" do
    it "returns days until tournament starts" do
      tournament = tournaments(:copa_america)
      expected_days = (tournament.starts_at.to_date - Date.current).to_i
      expect(tournament.days_until_start).to eq(expected_days)
    end

    it "returns nil when there are no fixtures" do
      tournament = Tournament.create!(name: "Empty Tournament")
      expect(tournament.days_until_start).to be_nil
    end
  end

  describe ".starting_within" do
    it "returns tournaments starting within given days" do
      tournament = tournaments(:copa_america)
      tournament.fixtures.update_all(kickoff_at: 5.days.from_now)
      tournaments_soon = Tournament.starting_within(14)
      expect(tournaments_soon).to include(tournament)
    end

    it "excludes tournaments that already started" do
      tournament = tournaments(:copa_america)
      tournament.fixtures.update_all(kickoff_at: 1.day.ago)
      tournaments_soon = Tournament.starting_within(14)
      expect(tournaments_soon).not_to include(tournament)
    end
  end
end
