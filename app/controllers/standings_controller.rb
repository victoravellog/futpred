class StandingsController < ApplicationController
  include TournamentScoped

  before_action :set_tournament
  before_action :set_tournament_context

  def show
    @standings = @tournament.standings.includes(:team).ordered
  end

  private

  def set_tournament
    @tournament = Tournament.joins(:organization_tournaments)
                            .joins("INNER JOIN memberships ON memberships.organization_id = organization_tournaments.organization_id")
                            .where(memberships: { user_id: Current.user.id })
                            .find(params[:tournament_id])
  end
end
