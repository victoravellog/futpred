class LeaderboardsController < ApplicationController
  def show
    @tournament = Tournament.joins(:organization_tournaments)
                            .joins("INNER JOIN memberships ON memberships.organization_id = organization_tournaments.organization_id")
                            .where(memberships: { user_id: Current.user.id })
                            .find(params[:tournament_id])

    points_subquery = Prediction.joins(fixture: :round)
                                 .where(rounds: { tournament_id: @tournament.id })
                                 .where.not(points_earned: nil)
                                 .group(:user_id)
                                 .select("user_id, SUM(points_earned) as total_points")

    @rankings = User.joins(:memberships)
                    .joins("INNER JOIN organization_tournaments ON organization_tournaments.organization_id = memberships.organization_id")
                    .where(organization_tournaments: { tournament_id: @tournament.id })
                    .joins("LEFT JOIN (#{points_subquery.to_sql}) points ON points.user_id = users.id")
                    .select("users.*, COALESCE(points.total_points, 0) as total_points")
                    .group("users.id, points.total_points")
                    .order("total_points DESC, users.email_address ASC")
  end
end
