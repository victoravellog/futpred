require 'rails_helper'

RSpec.describe "Dashboard", type: :request do
  fixtures :all

  describe "GET /" do
    context "when authenticated" do
      before { sign_in(users(:victor)) }

      it "returns http success" do
        get root_path
        expect(response).to have_http_status(:success)
      end

      it "displays user organizations" do
        get root_path
        expect(response.body).to include(organizations(:liga_amigos).name)
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        get root_path
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
