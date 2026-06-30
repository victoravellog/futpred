class User < ApplicationRecord
  attr_accessor :terms_accepted

  THEMES = %w[dark light pitch].freeze

  AVATAR_PRESETS = {
    "soccer_ball" => "⚽",
    "goal" => "🥅",
    "trophy" => "🏆",
    "whistle" => "📣",
    "gloves" => "🧤",
    "stadium" => "🏟️",
    "star" => "⭐",
    "fire" => "🔥",
    "lightning" => "⚡",
    "crown" => "👑",
    "rocket" => "🚀",
    "alien" => "👽"
  }.freeze

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships
  has_many :predictions, dependent: :destroy
  has_many :tournament_notifications, dependent: :destroy
  has_one_attached :avatar

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true
  validates :avatar_preset, inclusion: { in: AVATAR_PRESETS.keys }, allow_blank: true
  validates :theme, inclusion: { in: THEMES }
  validates :terms_accepted, acceptance: { message: :must_accept_terms }, on: :create
  validate :acceptable_avatar

  def display_name
    name.presence || email_address.split("@").first
  end

  def avatar_emoji
    AVATAR_PRESETS[avatar_preset]
  end

  private

  def acceptable_avatar
    return unless avatar.attached?

    unless avatar.blob.content_type.start_with?("image/")
      errors.add(:avatar, "must be an image")
    end

    if avatar.blob.byte_size > 5.megabytes
      errors.add(:avatar, "is too large (max 5MB)")
    end
  end
end
