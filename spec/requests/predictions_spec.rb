require 'rails_helper'

RSpec.describe "Predictions", type: :request do
  describe "GET /create" do
    it "returns http success" do
      pending "needs authentication setup"
      get "/predictions/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      pending "needs authentication setup"
      get "/predictions/update"
      expect(response).to have_http_status(:success)
    end
  end
end
