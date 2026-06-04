class ApplicationController < ActionController::Base
  include Authentication
  include MetaTags::ControllerHelper
  include MetaTagsDefaults
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  around_action :switch_locale
  after_action :set_noindex_for_authenticated_pages

  private

  def switch_locale(&action)
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def set_noindex_for_authenticated_pages
    set_meta_tags(robots: "noindex, nofollow") if authenticated?
  end
end
