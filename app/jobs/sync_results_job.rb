class SyncResultsJob < ApplicationJob
  queue_as :default

  def perform
    Tournament.find_each do |tournament|
      SyncResults.call(tournament: tournament)
    end
  end
end
