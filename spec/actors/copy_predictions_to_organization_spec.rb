require "rails_helper"

RSpec.describe CopyPredictionsToOrganization do
  fixtures :users, :organizations, :tournaments, :organization_tournaments, :rounds, :teams, :fixtures, :predictions, :memberships

  let(:victor) { users(:victor) }
  let(:oficina) { organizations(:oficina) }
  let(:liga_amigos) { organizations(:liga_amigos) }
  let(:oficina_copa_america) { organization_tournaments(:oficina_copa_america) }
  let(:argentina_brasil) { fixtures(:argentina_brasil) }

  describe ".call" do
    context "when user has predictions in another group for same tournament" do
      it "copies predictions to the new organization" do
        expect {
          described_class.call(user: victor, organization: oficina)
        }.to change { oficina_copa_america.predictions.count }.by(1)

        copied_prediction = oficina_copa_america.predictions.find_by(user: victor, fixture: argentina_brasil)
        original_prediction = predictions(:victor_argentina_brasil)

        expect(copied_prediction).to be_present
        expect(copied_prediction.predicted_home_score).to eq(original_prediction.predicted_home_score)
        expect(copied_prediction.predicted_away_score).to eq(original_prediction.predicted_away_score)
      end
    end

    context "when prediction already exists in target organization" do
      before do
        oficina_copa_america.predictions.create!(
          user: victor,
          fixture: argentina_brasil,
          predicted_home_score: 0,
          predicted_away_score: 0
        )
      end

      it "does not overwrite existing prediction" do
        expect {
          described_class.call(user: victor, organization: oficina)
        }.not_to change { oficina_copa_america.predictions.count }

        prediction = oficina_copa_america.predictions.find_by(user: victor, fixture: argentina_brasil)
        expect(prediction.predicted_home_score).to eq(0)
        expect(prediction.predicted_away_score).to eq(0)
      end
    end

    context "when fixture has already finished" do
      it "does not copy prediction for finished fixture" do
        finished_fixture = fixtures(:argentina_chile_finished)

        expect {
          described_class.call(user: victor, organization: oficina)
        }.not_to change { oficina_copa_america.predictions.where(fixture: finished_fixture).count }
      end
    end

    context "when user has no predictions to copy" do
      let(:maria) { users(:maria) }

      it "does nothing" do
        expect {
          described_class.call(user: maria, organization: oficina)
        }.not_to change { Prediction.count }
      end
    end
  end
end
