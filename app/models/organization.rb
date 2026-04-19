class Organization < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :organization_tournaments, dependent: :destroy
  has_many :tournaments, through: :organization_tournaments

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, on: :create

  private

  def generate_slug
    return if slug.present?
    self.slug = name&.parameterize
  end
end
