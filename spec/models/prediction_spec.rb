require 'rails_helper'

RSpec.describe Prediction, type: :model do
  fixtures :all

  describe "validations" do
    it "requires predicted_home_score" do
      prediction = Prediction.new(predicted_home_score: nil)
      expect(prediction).not_to be_valid
      expect(prediction.errors[:predicted_home_score]).to be_present
    end

    it "requires predicted_away_score" do
      prediction = Prediction.new(predicted_away_score: nil)
      expect(prediction).not_to be_valid
      expect(prediction.errors[:predicted_away_score]).to be_present
    end

    it "requires non-negative scores" do
      prediction = Prediction.new(predicted_home_score: -1, predicted_away_score: -1)
      expect(prediction).not_to be_valid
    end

    it "prevents duplicate predictions for same user/fixture/org_tournament" do
      existing = predictions(:victor_argentina_brasil)
      duplicate = Prediction.new(
        user: existing.user,
        fixture: existing.fixture,
        organization_tournament: existing.organization_tournament,
        predicted_home_score: 3,
        predicted_away_score: 0
      )
      expect(duplicate).not_to be_valid
    end
  end

  describe "#predicted_result" do
    it "returns :home_win when home score is higher" do
      prediction = Prediction.new(predicted_home_score: 2, predicted_away_score: 1)
      expect(prediction.predicted_result).to eq(:home_win)
    end

    it "returns :away_win when away score is higher" do
      prediction = Prediction.new(predicted_home_score: 0, predicted_away_score: 2)
      expect(prediction.predicted_result).to eq(:away_win)
    end

    it "returns :draw when scores are equal" do
      prediction = Prediction.new(predicted_home_score: 1, predicted_away_score: 1)
      expect(prediction.predicted_result).to eq(:draw)
    end
  end

  describe "#exact_score?" do
    it "returns true when prediction matches fixture score exactly" do
      prediction = predictions(:victor_finished)
      expect(prediction.exact_score?).to be true
    end

    it "returns false when prediction does not match" do
      prediction = predictions(:victor_argentina_brasil)
      prediction.fixture.update!(status: :finished, home_score: 3, away_score: 0)
      expect(prediction.exact_score?).to be false
    end
  end

  describe "#correct_result?" do
    it "returns true when predicted result matches actual result" do
      prediction = predictions(:victor_finished)
      expect(prediction.correct_result?).to be true
    end

    it "returns false when predicted result differs" do
      prediction = predictions(:victor_argentina_brasil)
      prediction.fixture.update!(status: :finished, home_score: 0, away_score: 1)
      expect(prediction.correct_result?).to be false
    end
  end
end
