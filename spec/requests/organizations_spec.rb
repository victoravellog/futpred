require 'rails_helper'

RSpec.describe "Organizations", type: :request do
  fixtures :all

  let(:user) { users(:victor) }
  let(:organization) { organizations(:liga_amigos) }

  describe "GET /organizations/:id" do
    context "when authenticated" do
      before { sign_in(user) }

      it "returns http success" do
        get organization_path(organization)
        expect(response).to have_http_status(:success)
      end

      it "displays organization name" do
        get organization_path(organization)
        expect(response.body).to include(organization.name)
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        get organization_path(organization)
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "GET /organizations/new" do
    context "when authenticated" do
      before { sign_in(user) }

      it "returns http success" do
        get new_organization_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /organizations" do
    context "when authenticated" do
      before { sign_in(user) }

      it "creates an organization" do
        expect {
          post organizations_path, params: { organization: { name: "New Org" } }
        }.to change(Organization, :count).by(1)
      end

      it "redirects after creation" do
        post organizations_path, params: { organization: { name: "New Org" } }
        expect(response).to have_http_status(:redirect)
      end
    end
  end
end
