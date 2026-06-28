class TournamentReminderMailer < ApplicationMailer
  def tournament_starting_soon(user:, tournament:, days_until:, reminder_type: nil, locale: "es")
    @user = user
    @tournament = tournament
    @days_until = days_until
    @locale = locale.to_sym
    @reminder_type = reminder_type&.to_sym || infer_reminder_type(days_until)
    @current_month = I18n.l(Date.current, format: "%B", locale: @locale)

    I18n.with_locale(@locale) do
      mail(
        to: @user.email_address,
        subject: t("mailer.tournament_reminder.subject.#{@reminder_type}",
                   tournament: @tournament.name,
                   month: @current_month)
      )
    end
  end

  def new_fixtures_available(user:, tournament:, new_fixtures_count:, locale: "es")
    @user = user
    @tournament = tournament
    @new_fixtures_count = new_fixtures_count
    @locale = locale.to_sym
    @next_fixture = tournament.fixtures.where(status: :scheduled).order(:kickoff_at).first

    I18n.with_locale(@locale) do
      mail(
        to: @user.email_address,
        subject: t("mailer.tournament_reminder.subject.new_fixtures", tournament: @tournament.name)
      )
    end
  end

  private

  def infer_reminder_type(days)
    case days
    when 6..8 then :one_week
    when 0..2 then :one_day
    else :soon
    end
  end
end
