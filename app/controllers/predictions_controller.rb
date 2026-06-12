class PredictionsController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_fixture
  before_action :set_organization_tournament
  before_action :set_prediction, only: [ :update ]
  before_action :set_user_in_multiple_groups

  def show
    @prediction = @organization_tournament.predictions.find_by(user: Current.user, fixture: @fixture) ||
                  @fixture.predictions.build
    render partial: "predictions/form", locals: {
      fixture: @fixture,
      prediction: @prediction,
      organization_tournament: @organization_tournament,
      user_in_multiple_groups: @user_in_multiple_groups
    }
  end

  def create
    @prediction = @organization_tournament.predictions.find_or_initialize_by(
      user: Current.user,
      fixture: @fixture
    )
    @prediction.assign_attributes(prediction_params)

    if @prediction.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to tournament_path(@fixture.round.tournament), notice: "Predicción guardada" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id(@fixture, :prediction_form), partial: "predictions/form", locals: { fixture: @fixture, prediction: @prediction, organization_tournament: @organization_tournament, user_in_multiple_groups: @user_in_multiple_groups }) }
        format.html { redirect_to tournament_path(@fixture.round.tournament), alert: @prediction.errors.full_messages.join(", ") }
      end
    end
  end

  def update
    if params[:apply_scope] == "all"
      update_all_groups
    else
      update_current_group
    end
  end

  private

  def update_current_group
    if @prediction.update(prediction_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to tournament_path(@fixture.round.tournament), notice: "Predicción actualizada" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id(@fixture, :prediction_form), partial: "predictions/form", locals: { fixture: @fixture, prediction: @prediction, organization_tournament: @organization_tournament, user_in_multiple_groups: @user_in_multiple_groups }) }
        format.html { redirect_to tournament_path(@fixture.round.tournament), alert: @prediction.errors.full_messages.join(", ") }
      end
    end
  end

  def update_all_groups
    tournament = @fixture.round.tournament
    user_org_tournaments = OrganizationTournament
      .joins(organization: :memberships)
      .where(tournament: tournament, memberships: { user_id: Current.user.id })

    Prediction.transaction do
      user_org_tournaments.each do |org_tournament|
        prediction = org_tournament.predictions.find_or_initialize_by(
          user: Current.user,
          fixture: @fixture
        )
        prediction.assign_attributes(prediction_params)
        prediction.save!
      end
    end

    @prediction.reload

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to tournament_path(@fixture.round.tournament), notice: "Predicción actualizada en todos los grupos" }
    end
  rescue ActiveRecord::RecordInvalid => e
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id(@fixture, :prediction_form), partial: "predictions/form", locals: { fixture: @fixture, prediction: @prediction, organization_tournament: @organization_tournament, user_in_multiple_groups: @user_in_multiple_groups }) }
      format.html { redirect_to tournament_path(@fixture.round.tournament), alert: e.record.errors.full_messages.join(", ") }
    end
  end

  def set_fixture
    @fixture = Fixture.joins(round: { tournament: :organization_tournaments })
                      .joins("INNER JOIN memberships ON memberships.organization_id = organization_tournaments.organization_id")
                      .where(memberships: { user_id: Current.user.id })
                      .find(params[:fixture_id])
  end

  def set_organization_tournament
    tournament = @fixture.round.tournament
    @organization_tournament = if params[:organization_tournament_id].present?
      OrganizationTournament
        .joins(organization: :memberships)
        .where(id: params[:organization_tournament_id], memberships: { user_id: Current.user.id })
        .first!
    else
      OrganizationTournament
        .joins(organization: :memberships)
        .where(tournament: tournament, memberships: { user_id: Current.user.id })
        .first!
    end
  end

  def set_prediction
    @prediction = @organization_tournament.predictions.find_by!(user: Current.user, fixture: @fixture)
  end

  def prediction_params
    params.require(:prediction).permit(:predicted_home_score, :predicted_away_score)
  end

  def set_user_in_multiple_groups
    tournament = @fixture.round.tournament
    @user_in_multiple_groups = Current.user.organizations
                                           .joins(:organization_tournaments)
                                           .where(organization_tournaments: { tournament_id: tournament.id })
                                           .count > 1
  end
end
