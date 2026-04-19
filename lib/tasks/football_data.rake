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
  task :import, [:code] => :environment do |_t, args|
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
end
