class Organization < ApplicationRecord
  LOCALES = %w[es en].freeze
  FREE_MEMBERS_LIMIT = 20

  enum :plan, { free: 0, pro: 1, enterprise: 2 }

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :organization_tournaments, dependent: :destroy
  has_many :tournaments, through: :organization_tournaments

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :invite_token, presence: true, uniqueness: true
  validates :locale, presence: true, inclusion: { in: LOCALES }

  before_validation :generate_slug, on: :create
  before_validation :generate_invite_token, on: :create

  def owner
    memberships.find_by(role: :owner)&.user
  end

  def members_limit
    free? ? FREE_MEMBERS_LIMIT : Float::INFINITY
  end

  def can_add_members?
    memberships.count < members_limit
  end

  def invite_url(host:)
    "#{host}/invite/#{invite_token}"
  end

  private

  def generate_slug
    return if slug.present?
    self.slug = name&.parameterize
  end

  def generate_invite_token
    return if invite_token.present?
    self.invite_token = SecureRandom.urlsafe_base64(8)
  end
end
