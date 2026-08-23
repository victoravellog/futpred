require 'rails_helper'

RSpec.describe "Invites", type: :request do
  fixtures :all

  describe "GET /invite/:token" do
    context "when authenticated and not a member" do
      before { sign_in(users(:maria)) }

      it "shows the invite page instead of redirecting to registration" do
        get invite_path(organizations(:liga_amigos).invite_token)
        expect(response).to have_http_status(:success)
        expect(response.body).to include(organizations(:liga_amigos).name)
      end
    end

    context "when authenticated and already a member" do
      before { sign_in(users(:victor)) }

      it "redirects to the organization" do
        get invite_path(organizations(:liga_amigos).invite_token)
        expect(response).to redirect_to(organization_path(organizations(:liga_amigos)))
      end
    end

    context "when not authenticated" do
      it "stores the invite token and redirects to registration" do
        get invite_path(organizations(:liga_amigos).invite_token)
        expect(response).to redirect_to(new_registration_path)
      end
    end
  end

  describe "POST /invite/:token/accept" do
    context "when authenticated and not a member" do
      before { sign_in(users(:maria)) }

      it "joins the organization" do
        expect {
          post accept_invite_path(organizations(:liga_amigos).invite_token)
        }.to change { users(:maria).organizations.count }.by(1)

        expect(response).to redirect_to(organization_path(organizations(:liga_amigos)))
      end
    end
  end
end
