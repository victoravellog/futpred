class TournamentsController < ApplicationController
  include TournamentScoped

  before_action :set_organization, only: [ :index, :new, :create ]
  before_action :set_tournament, only: [ :show ]
  before_action :set_tournament_context, only: [ :show ]

  def index
    @tournaments = @organization.tournaments.order(created_at: :desc)
  end

  def show
    @rounds = @tournament.rounds.includes(fixtures: [ :home_team, :away_team, :predictions ])
    @user_predictions = @organization_tournament.predictions
                                                 .where(user: Current.user)
                                                 .index_by(&:fixture_id)
    @user_points = @organization_tournament.predictions
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
    copy_predictions_for_members
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

  def copy_predictions_for_members
    @organization.users.find_each do |user|
      CopyPredictionsToOrganization.call(user: user, organization: @organization)
    end
  end

  def set_tournament
    @tournament = Tournament.joins(:organization_tournaments)
                            .joins("INNER JOIN memberships ON memberships.organization_id = organization_tournaments.organization_id")
                            .where(memberships: { user_id: Current.user.id })
                            .find(params[:id])
  end
end
