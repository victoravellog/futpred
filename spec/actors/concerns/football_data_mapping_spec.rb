require "rails_helper"

RSpec.describe FootballDataMapping do
  let(:test_class) do
    Class.new do
      include FootballDataMapping
      public :extract_scores, :map_status
    end
  end

  let(:mapper) { test_class.new }

  describe "#extract_scores" do
    context "with regular match (no penalties)" do
      let(:match_data) do
        {
          "score" => {
            "fullTime" => { "home" => 2, "away" => 1 },
            "halfTime" => { "home" => 1, "away" => 0 }
          }
        }
      end

      it "returns fullTime scores" do
        result = mapper.extract_scores(match_data)

        expect(result[:home]).to eq(2)
        expect(result[:away]).to eq(1)
        expect(result[:home_penalty]).to be_nil
        expect(result[:away_penalty]).to be_nil
      end
    end

    context "with penalty shootout" do
      let(:match_data) do
        {
          "score" => {
            "winner" => "AWAY_TEAM",
            "duration" => "PENALTY_SHOOTOUT",
            "fullTime" => { "home" => 3, "away" => 5 },
            "halfTime" => { "home" => 0, "away" => 1 },
            "regularTime" => { "home" => 1, "away" => 1 },
            "extraTime" => { "home" => 0, "away" => 0 },
            "penalties" => { "home" => 2, "away" => 4 }
          }
        }
      end

      it "returns regularTime + extraTime, NOT fullTime" do
        result = mapper.extract_scores(match_data)

        expect(result[:home]).to eq(1)
        expect(result[:away]).to eq(1)
        expect(result[:home_penalty]).to eq(2)
        expect(result[:away_penalty]).to eq(4)
      end

      it "does not include penalty goals in the score" do
        result = mapper.extract_scores(match_data)

        expect(result[:home]).not_to eq(3)
        expect(result[:away]).not_to eq(5)
      end
    end

    context "with extra time but no penalties" do
      let(:match_data) do
        {
          "score" => {
            "duration" => "EXTRA_TIME",
            "fullTime" => { "home" => 2, "away" => 1 },
            "regularTime" => { "home" => 1, "away" => 1 },
            "extraTime" => { "home" => 1, "away" => 0 }
          }
        }
      end

      it "returns fullTime scores (no penalty data present)" do
        result = mapper.extract_scores(match_data)

        expect(result[:home]).to eq(2)
        expect(result[:away]).to eq(1)
        expect(result[:home_penalty]).to be_nil
      end
    end

    context "with nil score data" do
      let(:match_data) { { "score" => nil } }

      it "returns nil scores" do
        result = mapper.extract_scores(match_data)

        expect(result[:home]).to be_nil
        expect(result[:away]).to be_nil
      end
    end
  end

  describe "#map_status" do
    it "maps SCHEDULED to :scheduled" do
      expect(mapper.map_status("SCHEDULED")).to eq(:scheduled)
    end

    it "maps TIMED to :scheduled" do
      expect(mapper.map_status("TIMED")).to eq(:scheduled)
    end

    it "maps IN_PLAY to :live" do
      expect(mapper.map_status("IN_PLAY")).to eq(:live)
    end

    it "maps PAUSED to :live" do
      expect(mapper.map_status("PAUSED")).to eq(:live)
    end

    it "maps FINISHED to :finished" do
      expect(mapper.map_status("FINISHED")).to eq(:finished)
    end

    it "maps POSTPONED to :cancelled" do
      expect(mapper.map_status("POSTPONED")).to eq(:cancelled)
    end

    it "maps unknown status to :scheduled" do
      expect(mapper.map_status("UNKNOWN")).to eq(:scheduled)
    end
  end
end
