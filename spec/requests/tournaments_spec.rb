require 'rails_helper'

RSpec.describe "Tournaments", type: :request do
  describe "GET /index" do
    it "returns http success" do
      pending "needs authentication setup"
      get "/tournaments/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      pending "needs authentication setup"
      get "/tournaments/show"
      expect(response).to have_http_status(:success)
    end
  end
end
