require 'rails_helper'

RSpec.describe "Leaderboards", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/leaderboards/show"
      expect(response).to have_http_status(:success)
    end
  end

end
