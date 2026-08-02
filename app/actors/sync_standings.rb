class SyncStandings < Actor
  input :tournament

  output :updated_count, default: 0

  def call
    return unless tournament.league?
    return unless tournament.external_id.present?

    standings_data = fetch_standings
    return if standings_data.empty?

    update_standings(standings_data)
  end

  private

  def client
    @client ||= FootballDataClient.new
  end

  def fetch_standings
    season = client.current_season(tournament.external_id)
    client.standings(tournament.external_id, season: season)
  rescue FootballDataClient::ApiError => e
    Rails.logger.error("SyncStandings API error for #{tournament.name}: #{e.message}")
    []
  end

  def update_standings(standings_data)
    standings_data.each do |data|
      team = find_team(data)
      next unless team

      standing = tournament.standings.find_or_initialize_by(team: team)
      standing.update!(
        position: data["position"],
        played_games: data["playedGames"],
        won: data["won"],
        draw: data["draw"],
        lost: data["lost"],
        points: data["points"],
        goals_for: data["goalsFor"],
        goals_against: data["goalsAgainst"],
        goal_difference: data["goalDifference"]
      )

      self.updated_count += 1
    end

    Rails.logger.info("SyncStandings: #{tournament.name} - #{updated_count} standings updated")
  end

  def find_team(data)
    team_id = data.dig("team", "id").to_s
    Team.find_by(external_id: team_id)
  end
end
