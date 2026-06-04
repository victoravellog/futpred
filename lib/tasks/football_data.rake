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
