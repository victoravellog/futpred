require 'rails_helper'

RSpec.describe "Tournaments", type: :request do
  fixtures :all

  describe "GET /tournaments/:id" do
    context "when authenticated" do
      before { sign_in(users(:victor)) }

      it "returns http success" do
        tournament = tournaments(:copa_america)
        get tournament_path(tournament)
        expect(response).to have_http_status(:success)
      end

      it "displays tournament name" do
        tournament = tournaments(:copa_america)
        get tournament_path(tournament)
        expect(response.body).to include(tournament.name)
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        tournament = tournaments(:copa_america)
        get tournament_path(tournament)
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
