class ProcessFixtureResultsJob < ApplicationJob
  queue_as :default

  def perform(fixture_id)
    fixture = Fixture.find(fixture_id)
    ProcessFixtureResults.call(fixture: fixture)
  end
end
