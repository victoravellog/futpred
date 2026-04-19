require "rails_helper"

RSpec.describe CalculatePredictionScore do
  fixtures :users, :organizations, :tournaments, :organization_tournaments, :rounds, :teams, :fixtures, :predictions

  let(:finished_fixture) { fixtures(:argentina_chile_finished) }
  let(:organization_tournament) { organization_tournaments(:liga_copa_america) }

  describe ".call" do
    context "when prediction has exact score" do
      it "awards 5 points times multiplier" do
        prediction = Prediction.new(
          user: users(:maria),
          fixture: finished_fixture,
          organization_tournament: organization_tournament,
          predicted_home_score: 2,
          predicted_away_score: 1
        )
        prediction.save!(validate: false)

        result = described_class.call(prediction: prediction)

        expect(result.success?).to be true
        expect(result.points).to eq(5)
        expect(prediction.reload.points_earned).to eq(5)
      end
    end

    context "when prediction has correct result but wrong score" do
      it "awards 3 points times multiplier" do
        prediction = Prediction.new(
          user: users(:maria),
          fixture: finished_fixture,
          organization_tournament: organization_tournament,
          predicted_home_score: 3,
          predicted_away_score: 0
        )
        prediction.save!(validate: false)

        result = described_class.call(prediction: prediction)

        expect(result.success?).to be true
        expect(result.points).to eq(3)
      end
    end

    context "when prediction is wrong" do
      it "awards 0 points" do
        prediction = Prediction.new(
          user: users(:maria),
          fixture: finished_fixture,
          organization_tournament: organization_tournament,
          predicted_home_score: 0,
          predicted_away_score: 2
        )
        prediction.save!(validate: false)

        result = described_class.call(prediction: prediction)

        expect(result.success?).to be true
        expect(result.points).to eq(0)
      end
    end

    context "when fixture is not finished" do
      it "awards 0 points" do
        prediction = predictions(:victor_argentina_brasil)

        result = described_class.call(prediction: prediction)

        expect(result.points).to eq(0)
      end
    end

    context "when points already calculated" do
      it "does not recalculate" do
        prediction = predictions(:victor_finished)

        result = described_class.call(prediction: prediction)

        expect(result.points).to eq(0)
        expect(prediction.reload.points_earned).to eq(5)
      end
    end
  end
end
