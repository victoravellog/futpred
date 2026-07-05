require 'rails_helper'

RSpec.describe Round, type: :model do
  fixtures :all

  describe "validations" do
    it "requires name" do
      round = Round.new(name: nil)
      expect(round).not_to be_valid
      expect(round.errors[:name]).to be_present
    end

    it "requires positive scoring_multiplier" do
      round = Round.new(name: "Test", scoring_multiplier: 0)
      expect(round).not_to be_valid
    end
  end

  describe "defaults" do
    it "sets scoring_multiplier to 1.0 if not provided" do
      round = Round.new(name: "Test", tournament: tournaments(:copa_america))
      round.valid?
      expect(round.scoring_multiplier).to eq(1.0)
    end
  end

  describe "associations" do
    it "has many fixtures ordered by kickoff" do
      round = rounds(:copa_grupos)
      expect(round.fixtures).to be_present
    end
  end

  describe "#finished?" do
    it "returns false when round has no fixtures" do
      round = Round.new(name: "Empty", tournament: tournaments(:copa_america))
      round.save!
      expect(round.finished?).to be false
    end

    it "returns false when some fixtures are not finished" do
      round = rounds(:copa_grupos)
      round.fixtures.first.update!(status: :scheduled, home_score: nil, away_score: nil)
      expect(round.finished?).to be false
    end

    it "returns true when all fixtures are finished" do
      round = rounds(:copa_grupos)
      round.fixtures.update_all(status: :finished, home_score: 1, away_score: 0)
      expect(round.finished?).to be true
    end
  end
end
