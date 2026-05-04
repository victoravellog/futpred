class PredictionsController < ApplicationController
  include ActionView::RecordIdentifier

  before_action :set_fixture
  before_action :set_prediction, only: [ :update ]

  def show
    @prediction = @fixture.predictions.find_by(user: Current.user) || @fixture.predictions.build
    render partial: "predictions/form", locals: { fixture: @fixture, prediction: @prediction }
  end

  def create
    @prediction = @fixture.predictions.build(prediction_params)
    @prediction.user = Current.user
    @prediction.organization_tournament = find_organization_tournament

    if @prediction.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to tournament_path(@fixture.round.tournament), notice: "Predicción guardada" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id(@fixture, :prediction_form), partial: "predictions/form", locals: { fixture: @fixture, prediction: @prediction }) }
        format.html { redirect_to tournament_path(@fixture.round.tournament), alert: @prediction.errors.full_messages.join(", ") }
      end
    end
  end

  def update
    if @prediction.update(prediction_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to tournament_path(@fixture.round.tournament), notice: "Predicción actualizada" }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(dom_id(@fixture, :prediction_form), partial: "predictions/form", locals: { fixture: @fixture, prediction: @prediction }) }
        format.html { redirect_to tournament_path(@fixture.round.tournament), alert: @prediction.errors.full_messages.join(", ") }
      end
    end
  end

  private

  def set_fixture
    @fixture = Fixture.joins(round: { tournament: :organization_tournaments })
                      .joins("INNER JOIN memberships ON memberships.organization_id = organization_tournaments.organization_id")
                      .where(memberships: { user_id: Current.user.id })
                      .find(params[:fixture_id])
  end

  def set_prediction
    @prediction = @fixture.predictions.find_by!(user: Current.user)
  end

  def prediction_params
    params.require(:prediction).permit(:predicted_home_score, :predicted_away_score)
  end

  def find_organization_tournament
    tournament = @fixture.round.tournament
    OrganizationTournament
      .joins(organization: :memberships)
      .where(tournament: tournament, memberships: { user_id: Current.user.id })
      .first
  end
end
