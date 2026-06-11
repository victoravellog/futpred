class SyncResultsJob < ApplicationJob
  queue_as :default

  def perform
    return unless should_sync?

    active_tournaments.find_each do |tournament|
      result = SyncResults.call(tournament: tournament)
      Rails.logger.info("SyncResults: #{tournament.name} - #{result.updated_count} fixtures updated")
    end
  end

  private

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
