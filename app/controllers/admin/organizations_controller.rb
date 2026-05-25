module Admin
  class OrganizationsController < BaseController
    def index
      @organizations = Organization
        .left_joins(:memberships, :organization_tournaments)
        .select(
          "organizations.*",
          "COUNT(DISTINCT memberships.id) AS members_count",
          "COUNT(DISTINCT organization_tournaments.id) AS tournaments_count"
        )
        .group("organizations.id")
        .order(created_at: :desc)
    end

    def show
      @organization = Organization.find(params[:id])
      @members = @organization.users.includes(:predictions)
      @tournaments = @organization.tournaments
      @predictions_count = Prediction
        .joins(:organization_tournament)
        .where(organization_tournaments: { organization_id: @organization.id })
        .count
    end
  end
end
