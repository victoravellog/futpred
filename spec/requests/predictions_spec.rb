require 'rails_helper'

RSpec.describe "Predictions", type: :request do
  fixtures :all

  let(:user) { users(:victor) }
  let(:fixture_record) { fixtures(:chile_colombia) }
  let(:org_tournament) { organization_tournaments(:liga_copa_america) }

  describe "POST /fixtures/:fixture_id/prediction" do
    context "when authenticated" do
      before { sign_in(user) }

      it "creates a prediction" do
        expect {
          post fixture_prediction_path(fixture_record), params: {
            prediction: { predicted_home_score: 2, predicted_away_score: 1 }
          }
        }.to change(Prediction, :count).by(1)
      end

      it "redirects or responds with turbo_stream" do
        post fixture_prediction_path(fixture_record), params: {
          prediction: { predicted_home_score: 2, predicted_away_score: 1 }
        }
        expect(response).to have_http_status(:success).or have_http_status(:redirect)
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        post fixture_prediction_path(fixture_record), params: {
          prediction: { predicted_home_score: 2, predicted_away_score: 1 }
        }
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "PATCH /fixtures/:fixture_id/prediction" do
    context "when authenticated" do
      before { sign_in(user) }

      let!(:prediction) do
        Prediction.create!(
          user: user,
          fixture: fixture_record,
          organization_tournament: org_tournament,
          predicted_home_score: 1,
          predicted_away_score: 0
        )
      end

      it "updates the prediction" do
        patch fixture_prediction_path(fixture_record), params: {
          organization_tournament_id: org_tournament.id,
          prediction: { predicted_home_score: 3, predicted_away_score: 2 }
        }
        prediction.reload
        expect(prediction.predicted_home_score).to eq(3)
        expect(prediction.predicted_away_score).to eq(2)
      end
    end
  end
end
