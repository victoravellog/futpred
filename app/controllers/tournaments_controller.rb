class TournamentsController < ApplicationController
  before_action :set_organization, only: [ :index, :new, :create ]
  before_action :set_tournament, only: [ :show ]

  def index
    @tournaments = @organization.tournaments.order(created_at: :desc)
  end

  def show
    @rounds = @tournament.rounds.includes(fixtures: [ :home_team, :away_team, :predictions ])
  end

  def new
    @tournament = @organization.tournaments.build
  end

  def create
    @tournament = @organization.tournaments.build(tournament_params)
    if @tournament.save
      redirect_to organization_tournaments_path(@organization), notice: "Torneo creado exitosamente"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_organization
    @organization = Current.user.organizations.find(params[:organization_id])
  end

  def set_tournament
    @tournament = Tournament.joins(organization: :memberships)
                            .where(memberships: { user_id: Current.user.id })
                            .find(params[:id])
  end

  def tournament_params
    params.require(:tournament).permit(:name)
  end
end
