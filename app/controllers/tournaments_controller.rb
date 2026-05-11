class TournamentsController < ApplicationController
  before_action :set_organization, only: [ :index, :new, :create ]
  before_action :set_tournament, only: [ :show ]

  def index
    @tournaments = @organization.tournaments.order(created_at: :desc)
  end

  def show
    user_orgs_with_tournament = Current.user.organizations
                                            .joins(:organization_tournaments)
                                            .where(organization_tournaments: { tournament_id: @tournament.id })

    @organization = if params[:organization_id].present?
                      user_orgs_with_tournament.find(params[:organization_id])
                    else
                      user_orgs_with_tournament.first!
                    end

    @rounds = @tournament.rounds.includes(fixtures: [ :home_team, :away_team, :predictions ])
    @user_points = Prediction.joins(fixture: :round)
                             .where(rounds: { tournament_id: @tournament.id })
                             .where(user: Current.user)
                             .sum(:points_earned)
  end

  def new
    existing_ids = @organization.tournament_ids
    @available_tournaments = Tournament.where.not(id: existing_ids).order(:name)
  end

  def create
    tournament = Tournament.find(params[:tournament_id])
    @organization.tournaments << tournament
    redirect_to organization_path(@organization), notice: t("tournaments.added")
  rescue ActiveRecord::RecordNotUnique
    redirect_to organization_path(@organization), alert: t("tournaments.already_added")
  rescue ActiveRecord::RecordNotFound
    redirect_to new_organization_tournament_path(@organization), alert: t("tournaments.not_found")
  end

  private

  def set_organization
    @organization = Current.user.organizations.find(params[:organization_id])
  end

  def set_tournament
    @tournament = Tournament.joins(:organization_tournaments)
                            .joins("INNER JOIN memberships ON memberships.organization_id = organization_tournaments.organization_id")
                            .where(memberships: { user_id: Current.user.id })
                            .find(params[:id])
  end
end
