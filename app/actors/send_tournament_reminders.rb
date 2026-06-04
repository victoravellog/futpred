class SendTournamentReminders < Actor
  DAYS_BEFORE_REMINDERS = {
    7 => "one_week",
    1 => "one_day"
  }.freeze

  output :emails_sent, default: 0
  output :banners_created, default: 0

  def call
    send_month_start_reminders if first_day_of_month?

    DAYS_BEFORE_REMINDERS.each do |days, notification_type|
      tournaments_starting_in(days).each do |tournament|
        send_reminders_for(tournament, tournament.days_until_start, notification_type)
      end
    end
  end

  private

  def first_day_of_month?
    Date.current.day == 1
  end

  def send_month_start_reminders
    tournaments_starting_this_month.each do |tournament|
      send_reminders_for(tournament, tournament.days_until_start, "month_start")
    end
  end

  def tournaments_starting_this_month
    Tournament.all.select do |t|
      t.starts_at.present? &&
        t.starts_at > Time.current &&
        t.starts_at.month == Date.current.month &&
        t.starts_at.year == Date.current.year
    end
  end

  def tournaments_starting_in(days)
    Tournament.starting_in(days)
  end

  def send_reminders_for(tournament, days, notification_type)
    users_to_notify(tournament).each do |user|
      send_email_reminder(user, tournament, days, notification_type)
      create_banner_notification(user, tournament, notification_type)
    end
  end

  def users_to_notify(tournament)
    User.joins(organizations: :organization_tournaments)
        .where(organization_tournaments: { tournament_id: tournament.id })
        .distinct
  end

  def send_email_reminder(user, tournament, days, notification_type)
    return if already_notified?(user, tournament, notification_type, "email")

    locale = preferred_locale_for(user, tournament)

    TournamentReminderMailer.tournament_starting_soon(
      user: user,
      tournament: tournament,
      days_until: days,
      reminder_type: notification_type,
      locale: locale
    ).deliver_later

    record_notification!(user, tournament, notification_type, "email")
    self.emails_sent += 1
  end

  def preferred_locale_for(user, tournament)
    memberships = user.memberships
                      .joins(organization: :organization_tournaments)
                      .where(organization_tournaments: { tournament_id: tournament.id })
                      .includes(:organization)
                      .order(role: :desc)

    memberships.first&.organization&.locale || "es"
  end

  def create_banner_notification(user, tournament, notification_type)
    return if already_notified?(user, tournament, notification_type, "banner")

    record_notification!(user, tournament, notification_type, "banner")
    self.banners_created += 1
  end

  def already_notified?(user, tournament, notification_type, channel)
    TournamentNotification.already_sent?(
      user: user,
      tournament: tournament,
      notification_type: notification_type,
      channel: channel
    )
  end

  def record_notification!(user, tournament, notification_type, channel)
    TournamentNotification.record_sent!(
      user: user,
      tournament: tournament,
      notification_type: notification_type,
      channel: channel
    )
  end
end
