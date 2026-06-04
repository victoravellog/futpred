require 'rails_helper'

RSpec.describe TournamentNotification, type: :model do
  fixtures :all

  describe "validations" do
    it "requires notification_type" do
      notification = TournamentNotification.new(
        user: users(:victor),
        tournament: tournaments(:copa_america),
        channel: "email",
        sent_at: Time.current
      )
      expect(notification).not_to be_valid
      expect(notification.errors[:notification_type]).to be_present
    end

    it "requires channel" do
      notification = TournamentNotification.new(
        user: users(:victor),
        tournament: tournaments(:copa_america),
        notification_type: "one_day",
        sent_at: Time.current
      )
      expect(notification).not_to be_valid
      expect(notification.errors[:channel]).to be_present
    end

    it "validates notification_type inclusion" do
      notification = TournamentNotification.new(
        user: users(:victor),
        tournament: tournaments(:copa_america),
        notification_type: "invalid",
        channel: "email",
        sent_at: Time.current
      )
      expect(notification).not_to be_valid
    end

    it "validates channel inclusion" do
      notification = TournamentNotification.new(
        user: users(:victor),
        tournament: tournaments(:copa_america),
        notification_type: "one_week",
        channel: "invalid",
        sent_at: Time.current
      )
      expect(notification).not_to be_valid
    end

    it "enforces uniqueness per user/tournament/type/channel" do
      existing = tournament_notifications(:one_week_email_victor)
      duplicate = TournamentNotification.new(
        user: existing.user,
        tournament: existing.tournament,
        notification_type: existing.notification_type,
        channel: existing.channel,
        sent_at: Time.current
      )
      expect(duplicate).not_to be_valid
    end
  end

  describe ".already_sent?" do
    it "returns true when notification exists" do
      existing = tournament_notifications(:one_week_email_victor)
      result = TournamentNotification.already_sent?(
        user: existing.user,
        tournament: existing.tournament,
        notification_type: existing.notification_type,
        channel: existing.channel
      )
      expect(result).to be true
    end

    it "returns false when notification does not exist" do
      result = TournamentNotification.already_sent?(
        user: users(:victor),
        tournament: tournaments(:copa_america),
        notification_type: "one_day",
        channel: "email"
      )
      expect(result).to be false
    end
  end

  describe ".record_sent!" do
    it "creates a new notification record" do
      expect {
        TournamentNotification.record_sent!(
          user: users(:victor),
          tournament: tournaments(:copa_america),
          notification_type: "one_day",
          channel: "banner"
        )
      }.to change(TournamentNotification, :count).by(1)
    end
  end
end
