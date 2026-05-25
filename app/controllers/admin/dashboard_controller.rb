module Admin
  class DashboardController < BaseController
    def show
      @stats = {
        total_users: User.count,
        total_organizations: Organization.count,
        total_predictions: Prediction.count,
        total_tournaments: Tournament.count
      }
      @recent_organizations = Organization.order(created_at: :desc).limit(5)
      @recent_users = User.order(created_at: :desc).limit(5)
    end
  end
end
