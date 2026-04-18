class LeaderboardsController < ApplicationController
  def show
    @tournament = Tournament.joins(organization: :memberships)
                            .where(memberships: { user_id: Current.user.id })
                            .find(params[:tournament_id])

    @rankings = User.joins(predictions: { fixture: :round })
                    .where(rounds: { tournament_id: @tournament.id })
                    .where.not(predictions: { points_earned: nil })
                    .group("users.id")
                    .select("users.*, SUM(predictions.points_earned) as total_points")
                    .order("total_points DESC")
  end
end
