class ImportCompetition < Actor
  include FootballDataMapping

  input :competition_code

  output :tournament

  def call
    data = client.competition(competition_code)

    self.tournament = Tournament.find_or_initialize_by(external_id: data["code"])
    tournament.update!(
      name: data["name"],
      logo_url: data["emblem"]
    )

    import_teams(data["code"])
    import_rounds(data)
  end

  private

  def client
    @client ||= FootballDataClient.new
  end

  def import_teams(competition_code)
    teams_data = client.teams(competition_code)

    teams_data.each do |team_data|
      team = Team.find_or_initialize_by(external_id: team_data["id"].to_s)
      raw_code = team_data["area"]&.dig("code")
      # Mantener códigos especiales (ENG, SCO, WAL) para banderas de subdivisión
      country_code = CountryCodes::SUBDIVISION_FLAGS.key?(raw_code&.upcase) ? raw_code&.upcase : CountryCodes.to_alpha2(raw_code)
      team.update!(
        name: team_data["name"],
        logo_url: team_data["crest"],
        country_code: country_code
      )

      unless tournament.teams.include?(team)
        tournament.teams << team
      end
    end
  end

  def import_rounds(competition_data)
    current_season = competition_data["currentSeason"]
    return unless current_season

    matches = client.matches(competition_code, season: current_season["startDate"].to_s[0..3].to_i)

    matches_by_stage = matches.group_by { |m| m["stage"] }

    matches_by_stage.each_with_index do |(stage, stage_matches), index|
      round = tournament.rounds.find_or_initialize_by(name: humanize_stage(stage))
      round.update!(
        position: index + 1,
        scoring_multiplier: multiplier_for_stage(stage)
      )

      import_fixtures(round, stage_matches)
    end
  end

  def import_fixtures(round, matches)
    matches.each do |match_data|
      home_team = Team.find_by(external_id: match_data["homeTeam"]["id"].to_s)
      away_team = Team.find_by(external_id: match_data["awayTeam"]["id"].to_s)

      next unless home_team && away_team

      scores = extract_scores(match_data)
      fixture = round.fixtures.find_or_initialize_by(external_id: match_data["id"].to_s)
      fixture.update!(
        home_team: home_team,
        away_team: away_team,
        kickoff_at: Time.parse(match_data["utcDate"]),
        status: map_status(match_data["status"]),
        home_score: scores[:home],
        away_score: scores[:away],
        home_penalty_score: scores[:home_penalty],
        away_penalty_score: scores[:away_penalty],
        group_name: humanize_group(match_data["group"])
      )
    end
  end

  def humanize_stage(stage)
    {
      "GROUP_STAGE" => "Fase de Grupos",
      "ROUND_OF_16" => "Octavos de Final",
      "QUARTER_FINALS" => "Cuartos de Final",
      "SEMI_FINALS" => "Semifinales",
      "FINAL" => "Final",
      "THIRD_PLACE" => "Tercer Puesto"
    }[stage] || stage.titleize
  end

  def multiplier_for_stage(stage)
    {
      "GROUP_STAGE" => 1.0,
      "ROUND_OF_16" => 1.25,
      "QUARTER_FINALS" => 1.5,
      "SEMI_FINALS" => 1.75,
      "FINAL" => 2.0,
      "THIRD_PLACE" => 1.5
    }[stage] || 1.0
  end

  def humanize_group(group)
    return nil unless group
    match = group.match(/GROUP_(\w+)/)
    match ? "Grupo #{match[1]}" : nil
  end
end
