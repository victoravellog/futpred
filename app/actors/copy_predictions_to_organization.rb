class CopyPredictionsToOrganization < Actor
  input :user, type: User
  input :organization, type: Organization

  def call
    organization.organization_tournaments.find_each do |org_tournament|
      copy_predictions_for_tournament(org_tournament)
    end
  end

  private

  def copy_predictions_for_tournament(org_tournament)
    existing_predictions = find_existing_predictions(org_tournament.tournament)
    return if existing_predictions.empty?

    existing_predictions.each do |prediction|
      next if org_tournament.predictions.exists?(user: user, fixture: prediction.fixture)

      org_tournament.predictions.create!(
        user: user,
        fixture: prediction.fixture,
        predicted_home_score: prediction.predicted_home_score,
        predicted_away_score: prediction.predicted_away_score
      )
    end
  end

  def find_existing_predictions(tournament)
    Prediction
      .joins(organization_tournament: :organization)
      .joins(:fixture)
      .where(user: user)
      .where(organization_tournaments: { tournament_id: tournament.id })
      .where.not(organization_tournaments: { organization_id: organization.id })
      .where(fixtures: { status: :scheduled })
      .where("fixtures.kickoff_at > ?", Time.current)
  end
end
