class SyncResultsJob < ApplicationJob
  queue_as :default

  def perform
    import_new_fixtures_if_needed
    return unless should_sync?

    active_tournaments.find_each do |tournament|
      result = SyncResults.call(tournament: tournament)
      Rails.logger.info("SyncResults: #{tournament.name} - #{result.updated_count} fixtures updated")
    end
  end

  private

  def import_new_fixtures_if_needed
    tournaments_to_import.find_each do |tournament|
      old_count = tournament.fixtures.count
      result = ImportCompetition.call(competition_code: tournament.external_id)

      next unless result.success?

      tournament.update!(last_imported_at: Time.current)
      new_count = tournament.fixtures.count

      if new_count > old_count
        new_fixtures_count = new_count - old_count
        Rails.logger.info("SyncResultsJob: Imported #{new_fixtures_count} new fixtures for #{tournament.name}")
        notify_new_fixtures(tournament, new_fixtures_count)
      end
    end
  end

  def tournaments_to_import
    Tournament.where.not(external_id: nil)
              .where(last_imported_at: nil)
              .or(Tournament.where.not(external_id: nil)
                            .where(last_imported_at: ...Date.current.beginning_of_day))
  end

  def notify_new_fixtures(tournament, count)
    users_to_notify(tournament).find_each do |user|
      locale = preferred_locale_for(user, tournament)
      TournamentReminderMailer.new_fixtures_available(
        user: user,
        tournament: tournament,
        new_fixtures_count: count,
        locale: locale
      ).deliver_later
    end
  end

  def users_to_notify(tournament)
    User.joins(organizations: :organization_tournaments)
        .where(organization_tournaments: { tournament_id: tournament.id })
        .distinct
  end

  def preferred_locale_for(user, tournament)
    membership = user.memberships
                     .joins(organization: :organization_tournaments)
                     .where(organization_tournaments: { tournament_id: tournament.id })
                     .includes(:organization)
                     .order(role: :desc)
                     .first

    membership&.organization&.locale || "es"
  end

  def should_sync?
    has_live_fixtures? || has_upcoming_fixtures?
  end

  def has_live_fixtures?
    Fixture.where(status: :live).exists?
  end

  def has_upcoming_fixtures?
    Fixture.where(status: :scheduled)
           .where(kickoff_at: 3.hours.ago..3.hours.from_now)
           .exists?
  end

  def active_tournaments
    Tournament.joins(:fixtures)
              .where(fixtures: { status: [ :scheduled, :live ] })
              .where(fixtures: { kickoff_at: 3.hours.ago.. })
              .distinct
  end
end
