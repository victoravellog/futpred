class PagesController < ApplicationController
  allow_unauthenticated_access

  def home
    redirect_to dashboard_path if authenticated?
  end

  def pricing
    @tournaments = Tournament.all.select { |t| t.starts_at.present? && t.starts_at > Time.current }.sort_by(&:starts_at)
  end

  def privacy
  end

  def terms
  end
end
