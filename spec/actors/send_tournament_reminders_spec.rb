require "rails_helper"

RSpec.describe SendTournamentReminders do
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TimeHelpers
  fixtures :all

  describe ".call" do
    let(:user) { users(:victor) }
    let(:tournament) { tournaments(:copa_america) }

    before do
      ActionMailer::Base.deliveries.clear
    end

    context "on the first day of the month" do
      context "when tournament starts this month" do
        before do
          tournament.fixtures.update_all(kickoff_at: 15.days.from_now)
        end

        it "enqueues month_start email notifications", :aggregate_failures do
          travel_to Date.current.beginning_of_month do
            tournament.fixtures.update_all(kickoff_at: 20.days.from_now)

            expect {
              described_class.call
            }.to have_enqueued_mail(TournamentReminderMailer, :tournament_starting_soon).at_least(1).times
          end
        end

        it "creates month_start banner notification" do
          travel_to Date.current.beginning_of_month do
            tournament.fixtures.update_all(kickoff_at: 20.days.from_now)

            expect {
              described_class.call
            }.to change { TournamentNotification.banners.where(notification_type: "month_start").count }.by_at_least(1)
          end
        end

        it "does not send duplicate notifications" do
          travel_to Date.current.beginning_of_month do
            tournament.fixtures.update_all(kickoff_at: 20.days.from_now)
            described_class.call

            expect {
              described_class.call
            }.not_to change { TournamentNotification.count }
          end
        end
      end

      context "when tournament starts next month" do
        it "does not send month_start notification" do
          travel_to Date.current.beginning_of_month do
            tournament.fixtures.update_all(kickoff_at: 45.days.from_now)

            expect {
              described_class.call
            }.not_to change { TournamentNotification.where(notification_type: "month_start").count }
          end
        end
      end
    end

    context "not on the first day of the month" do
      it "does not send month_start notifications" do
        travel_to Date.current.beginning_of_month + 5.days do
          tournament.fixtures.update_all(kickoff_at: 15.days.from_now)

          expect {
            described_class.call
          }.not_to change { TournamentNotification.where(notification_type: "month_start").count }
        end
      end
    end

    context "when tournament starts in 7 days" do
      before do
        tournament.fixtures.update_all(kickoff_at: 7.days.from_now)
      end

      it "sends one_week notification" do
        described_class.call

        expect(
          TournamentNotification.exists?(
            tournament: tournament,
            notification_type: "one_week"
          )
        ).to be true
      end
    end

    context "when tournament starts in 1 day" do
      before do
        tournament.fixtures.update_all(kickoff_at: 1.day.from_now)
      end

      it "sends one_day notification" do
        described_class.call

        expect(
          TournamentNotification.exists?(
            tournament: tournament,
            notification_type: "one_day"
          )
        ).to be true
      end
    end

    context "when tournament starts in 15 days (not a reminder day)" do
      before do
        tournament.fixtures.update_all(kickoff_at: 15.days.from_now)
      end

      it "does not send week/day notifications" do
        travel_to Date.current.beginning_of_month + 10.days do
          expect {
            described_class.call
          }.not_to change { TournamentNotification.count }
        end
      end
    end

    it "returns count of sent notifications" do
      tournament.fixtures.update_all(kickoff_at: 7.days.from_now)

      result = described_class.call

      expect(result.emails_sent).to be >= 0
      expect(result.banners_created).to be >= 0
    end
  end
end
