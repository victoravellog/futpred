class SendTournamentRemindersJob < ApplicationJob
  queue_as :default

  def perform
    result = SendTournamentReminders.call

    Rails.logger.info(
      "[TournamentReminders] Sent #{result.emails_sent} emails, " \
      "created #{result.banners_created} banner notifications"
    )
  end
end
