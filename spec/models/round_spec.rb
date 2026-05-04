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
end
