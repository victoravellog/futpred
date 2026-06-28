namespace :reminders do
  desc "Send tournament reminder notifications (run daily via cron)"
  task tournaments: :environment do
    SendTournamentRemindersJob.perform_now
  end

  desc "Notify users about new fixtures (e.g., rails reminders:new_fixtures[WC])"
  task :new_fixtures, [ :tournament_code ] => :environment do |_t, args|
    code = args[:tournament_code]
    abort "Usage: rails reminders:new_fixtures[TOURNAMENT_CODE]" unless code

    tournament = Tournament.find_by(external_id: code)
    abort "Tournament not found with code: #{code}" unless tournament

    new_fixtures = tournament.fixtures.where(status: :scheduled).count
    puts "Notifying users about #{new_fixtures} fixtures in #{tournament.name}..."

    users = User.joins(organizations: :organization_tournaments)
                .where(organization_tournaments: { tournament_id: tournament.id })
                .distinct

    count = 0
    users.find_each do |user|
      membership = user.memberships
                       .joins(organization: :organization_tournaments)
                       .where(organization_tournaments: { tournament_id: tournament.id })
                       .includes(:organization)
                       .first

      locale = membership&.organization&.locale || "es"

      TournamentReminderMailer.new_fixtures_available(
        user: user,
        tournament: tournament,
        new_fixtures_count: new_fixtures,
        locale: locale
      ).deliver_later

      count += 1
    end

    puts "Queued #{count} emails"
  end
end
