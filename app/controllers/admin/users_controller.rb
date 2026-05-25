module Admin
  class UsersController < BaseController
    def index
      @users = User
        .left_joins(:predictions, :memberships)
        .select(
          "users.*",
          "COUNT(DISTINCT predictions.id) AS predictions_count",
          "COUNT(DISTINCT memberships.id) AS organizations_count"
        )
        .group("users.id")
        .order(created_at: :desc)
    end

    def show
      @user = User.find(params[:id])
      @organizations = @user.organizations
    end
  end
end
