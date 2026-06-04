class TournamentReminderMailerPreview < ActionMailer::Preview
  def month_start_spanish
    TournamentReminderMailer.tournament_starting_soon(
      user: sample_user,
      tournament: sample_tournament,
      days_until: 15,
      reminder_type: "month_start",
      locale: "es"
    )
  end

  def month_start_english
    TournamentReminderMailer.tournament_starting_soon(
      user: sample_user,
      tournament: sample_tournament,
      days_until: 15,
      reminder_type: "month_start",
      locale: "en"
    )
  end

  def one_week_spanish
    TournamentReminderMailer.tournament_starting_soon(
      user: sample_user,
      tournament: sample_tournament,
      days_until: 7,
      reminder_type: "one_week",
      locale: "es"
    )
  end

  def one_week_english
    TournamentReminderMailer.tournament_starting_soon(
      user: sample_user,
      tournament: sample_tournament,
      days_until: 7,
      reminder_type: "one_week",
      locale: "en"
    )
  end

  def one_day_spanish
    TournamentReminderMailer.tournament_starting_soon(
      user: sample_user,
      tournament: sample_tournament,
      days_until: 1,
      reminder_type: "one_day",
      locale: "es"
    )
  end

  def one_day_english
    TournamentReminderMailer.tournament_starting_soon(
      user: sample_user,
      tournament: sample_tournament,
      days_until: 1,
      reminder_type: "one_day",
      locale: "en"
    )
  end

  private

  def sample_user
    User.first || OpenStruct.new(display_name: "Usuario Demo", email_address: "demo@example.com")
  end

  def sample_tournament
    Tournament.first || OpenStruct.new(name: "Mundial 2026")
  end
end
