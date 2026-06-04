namespace :reminders do
  desc "Send tournament reminder notifications (run daily via cron)"
  task tournaments: :environment do
    SendTournamentRemindersJob.perform_now
  end
end
