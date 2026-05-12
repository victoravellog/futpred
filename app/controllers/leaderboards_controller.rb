class LeaderboardsController < ApplicationController
  include TournamentScoped

  before_action :set_tournament
  before_action :set_tournament_context

  def show
    points_subquery = Prediction.where(organization_tournament: @organization_tournament)
                                 .where.not(points_earned: nil)
                                 .group(:user_id)
                                 .select("user_id, SUM(points_earned) as total_points")

    @rankings = User.joins(:memberships)
                    .where(memberships: { organization_id: @organization.id })
                    .joins("LEFT JOIN (#{points_subquery.to_sql}) points ON points.user_id = users.id")
                    .select("users.*, COALESCE(points.total_points, 0) as total_points")
                    .group("users.id, points.total_points")
                    .order("total_points DESC, users.email_address ASC")
  end

  private

  def set_tournament
    @tournament = Tournament.joins(:organization_tournaments)
                            .joins("INNER JOIN memberships ON memberships.organization_id = organization_tournaments.organization_id")
                            .where(memberships: { user_id: Current.user.id })
                            .find(params[:tournament_id])
  end
end
