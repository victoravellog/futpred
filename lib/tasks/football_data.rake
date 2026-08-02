namespace :football_data do
  desc "List available competitions from Football-Data.org"
  task competitions: :environment do
    client = FootballDataClient.new
    competitions = client.competitions

    puts "\nAvailable competitions:\n\n"
    competitions.each do |c|
      puts "#{c['code'].ljust(10)} #{c['name']} (#{c['area']['name']})"
    end
    puts "\nUse: rails football_data:import[CODE] to import a competition"
  end

  desc "Import a competition (e.g., rails football_data:import[WC])"
  task :import, [ :code ] => :environment do |_t, args|
    code = args[:code]
    abort "Usage: rails football_data:import[CODE]" unless code

    puts "Importing #{code}..."
    result = ImportCompetition.call(competition_code: code)

    if result.success?
      tournament = result.tournament
      puts "Imported: #{tournament.name}"
      puts "  Teams: #{tournament.teams.count}"
      puts "  Rounds: #{tournament.rounds.count}"
      puts "  Fixtures: #{tournament.fixtures.count}"
    else
      puts "Error: #{result.failure}"
    end
  end

  desc "Sync results for all tournaments"
  task sync: :environment do
    puts "Syncing results..."
    Tournament.find_each do |tournament|
      result = SyncResults.call(tournament: tournament)
      puts "#{tournament.name}: #{result.updated_count} fixtures updated"
    end
  end

  desc "Re-sync knockout fixtures to fix penalty scores and recalculate predictions"
  task fix_knockout_scores: :environment do
    client = FootballDataClient.new

    Tournament.find_each do |tournament|
      code = tournament.external_id
      next unless code

      puts "Processing #{tournament.name}..."

      begin
        matches = client.matches(code)
        matches_by_id = matches.index_by { |m| m["id"].to_s }

        # Check all finished fixtures - API data will tell us which had penalties
        tournament.fixtures.finished.find_each do |fixture|
          match_data = matches_by_id[fixture.external_id]
          next unless match_data

          score_data = match_data["score"]
          penalties = score_data&.dig("penalties")

          if penalties && penalties["home"].present?
            regular = score_data.dig("regularTime") || {}
            extra = score_data.dig("extraTime") || {}

            new_home = (regular["home"] || 0) + (extra["home"] || 0)
            new_away = (regular["away"] || 0) + (extra["away"] || 0)

            if fixture.home_score != new_home || fixture.away_score != new_away
              puts "  Fixing #{fixture.home_team.name} vs #{fixture.away_team.name}:"
              puts "    Old: #{fixture.home_score}-#{fixture.away_score}"
              puts "    New: #{new_home}-#{new_away} (#{penalties['home']}-#{penalties['away']} pen)"

              fixture.update!(
                home_score: new_home,
                away_score: new_away,
                home_penalty_score: penalties["home"],
                away_penalty_score: penalties["away"]
              )

              fixture.predictions.where.not(points_earned: nil).find_each do |prediction|
                old_points = prediction.points_earned
                prediction.update!(points_earned: nil)
                CalculatePredictionScore.call(prediction: prediction)
                puts "    Prediction #{prediction.id}: #{old_points} -> #{prediction.reload.points_earned} pts"
              end
            end
          end
        end
      rescue FootballDataClient::ApiError => e
        puts "  Error: #{e.message}"
      end
    end

    puts "Done!"
  end

  desc "Recalculate all prediction scores for finished fixtures"
  task recalculate_predictions: :environment do
    predictions = Prediction.joins(:fixture).where(fixtures: { status: :finished })

    puts "Recalculating #{predictions.count} predictions..."

    changed = 0
    predictions.find_each do |prediction|
      old_points = prediction.points_earned
      prediction.update_column(:points_earned, nil)
      CalculatePredictionScore.call(prediction: prediction)
      new_points = prediction.reload.points_earned

      if old_points != new_points
        fixture = prediction.fixture
        puts "  #{fixture.home_team.name} vs #{fixture.away_team.name}: " \
             "#{prediction.predicted_home_score}-#{prediction.predicted_away_score} " \
             "(#{old_points} -> #{new_points} pts)"
        changed += 1
      end
    end

    puts "Done! #{changed} predictions updated."
  end

  desc "Import Europe's top 5 leagues (PL, PD, BL1, SA, FL1)"
  task import_top5_leagues: :environment do
    leagues = {
      "PL" => "Premier League",
      "PD" => "La Liga",
      "BL1" => "Bundesliga",
      "SA" => "Serie A",
      "FL1" => "Ligue 1"
    }

    leagues.each_with_index do |(code, name), index|
      if index > 0
        puts "  Waiting 60s to avoid rate limit..."
        sleep(60)
      end

      import_with_retry(code, name)
    end

    puts "\nDone! Imported leagues:"
    Tournament.league.each do |t|
      puts "  - #{t.name}: #{t.fixtures.count} fixtures"
    end
  end

  def import_with_retry(code, name, retries: 3)
    puts "\nImporting #{name} (#{code})..."

    result = ImportCompetition.call(competition_code: code)

    if result.success?
      tournament = result.tournament
      puts "  Format: #{tournament.format}"
      puts "  Teams: #{tournament.teams.count}"
      puts "  Rounds: #{tournament.rounds.count}"
      puts "  Fixtures: #{tournament.fixtures.count}"
    else
      puts "  Error: #{result.failure}"
    end
  rescue FootballDataClient::ApiError => e
    if e.message.include?("429") && retries > 0
      wait_time = e.message.match(/Wait (\d+) seconds/)&.[](1)&.to_i || 60
      puts "  Rate limited. Waiting #{wait_time}s and retrying (#{retries} retries left)..."
      sleep(wait_time + 5)
      import_with_retry(code, name, retries: retries - 1)
    else
      puts "  Error importing #{name}: #{e.message}"
    end
  rescue StandardError => e
    puts "  Error importing #{name}: #{e.message}"
  end

  desc "Backfill group names for existing fixtures"
  task backfill_groups: :environment do
    client = FootballDataClient.new

    Tournament.find_each do |tournament|
      code = tournament.external_id
      next unless code

      puts "Backfilling groups for #{tournament.name}..."

      begin
        competition = client.competition(code)
        current_season = competition["currentSeason"]
        next unless current_season

        matches = client.matches(code, season: current_season["startDate"].to_s[0..3].to_i)
        updated = 0

        matches.each do |match_data|
          next unless match_data["group"]

          fixture = Fixture.find_by(external_id: match_data["id"].to_s)
          next unless fixture

          group_name = match_data["group"].match(/GROUP_(\w+)/)&.then { |m| "Grupo #{m[1]}" }
          if group_name && fixture.group_name != group_name
            fixture.update!(group_name: group_name)
            updated += 1
          end
        end

        puts "  Updated #{updated} fixtures"
      rescue FootballDataClient::ApiError => e
        puts "  Error: #{e.message}"
      end
    end
  end
end
