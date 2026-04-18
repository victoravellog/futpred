class ProcessFixtureResults < Actor
  input :fixture

  output :processed_count

  def call
    fail!(error: "Fixture no ha terminado") unless fixture.finished?

    self.processed_count = 0

    fixture.predictions.find_each do |prediction|
      result = CalculatePredictionScore.call(prediction: prediction)
      self.processed_count += 1 if result.success?
    end
  end
end
