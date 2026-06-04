module ApplicationHelper
  include MetaTags::ViewHelper

  def country_flag(country_code)
    CountryCodes.to_flag(country_code)
  end
end
