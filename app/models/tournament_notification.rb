class TournamentNotification < ApplicationRecord
  TYPES = %w[month_start one_week one_day].freeze
  CHANNELS = %w[email banner].freeze

  belongs_to :user
  belongs_to :tournament

  validates :notification_type, presence: true, inclusion: { in: TYPES }
  validates :channel, presence: true, inclusion: { in: CHANNELS }
  validates :sent_at, presence: true
  validates :notification_type, uniqueness: { scope: [ :user_id, :tournament_id, :channel ] }

  scope :emails, -> { where(channel: "email") }
  scope :banners, -> { where(channel: "banner") }

  def self.already_sent?(user:, tournament:, notification_type:, channel:)
    exists?(user: user, tournament: tournament, notification_type: notification_type, channel: channel)
  end

  def self.record_sent!(user:, tournament:, notification_type:, channel:)
    create!(
      user: user,
      tournament: tournament,
      notification_type: notification_type,
      channel: channel,
      sent_at: Time.current
    )
  end
end
