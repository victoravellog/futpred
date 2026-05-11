require 'rails_helper'

RSpec.describe "Profile", type: :request do
  fixtures :all

  describe "GET /profile" do
    context "when authenticated" do
      before { sign_in(users(:victor)) }

      it "returns http success" do
        get profile_path
        expect(response).to have_http_status(:success)
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        get profile_path
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "PATCH /profile" do
    context "when authenticated" do
      before { sign_in(users(:victor)) }

      it "updates the user name" do
        patch profile_path, params: { user: { name: "Victor Avello" } }
        expect(response).to redirect_to(profile_path)
        expect(users(:victor).reload.name).to eq("Victor Avello")
      end
    end
  end
end
