require 'rails_helper'

RSpec.describe Fixture, type: :model do
  fixtures :all

  describe "validations" do
    it "requires kickoff_at" do
      fixture = Fixture.new(kickoff_at: nil)
      expect(fixture).not_to be_valid
      expect(fixture.errors[:kickoff_at]).to be_present
    end
  end

  describe "#finished?" do
    it "returns true when status is finished and scores are present" do
      fixture = fixtures(:argentina_chile_finished)
      expect(fixture.finished?).to be true
    end

    it "returns false when status is scheduled" do
      fixture = fixtures(:argentina_brasil)
      expect(fixture.finished?).to be false
    end
  end

  describe "#predictable?" do
    it "returns true when scheduled and kickoff is in the future" do
      fixture = fixtures(:argentina_brasil)
      expect(fixture.predictable?).to be true
    end

    it "returns false when finished" do
      fixture = fixtures(:argentina_chile_finished)
      expect(fixture.predictable?).to be false
    end

    it "returns false when kickoff has passed" do
      fixture = fixtures(:argentina_brasil)
      fixture.kickoff_at = 1.hour.ago
      expect(fixture.predictable?).to be false
    end
  end

  describe "#live?" do
    it "returns true when status is live" do
      fixture = fixtures(:argentina_brasil)
      fixture.status = :live
      expect(fixture.live?).to be true
    end

    it "returns false when status is scheduled" do
      fixture = fixtures(:argentina_brasil)
      expect(fixture.live?).to be false
    end
  end

  describe "#result" do
    it "returns :home_win when home team wins" do
      fixture = fixtures(:argentina_chile_finished)
      expect(fixture.result).to eq(:home_win)
    end

    it "returns :away_win when away team wins" do
      fixture = fixtures(:argentina_chile_finished)
      fixture.home_score = 0
      fixture.away_score = 2
      expect(fixture.result).to eq(:away_win)
    end

    it "returns :draw when scores are equal" do
      fixture = fixtures(:argentina_chile_finished)
      fixture.home_score = 1
      fixture.away_score = 1
      expect(fixture.result).to eq(:draw)
    end

    it "returns nil when not finished" do
      fixture = fixtures(:argentina_brasil)
      expect(fixture.result).to be_nil
    end
  end
end
