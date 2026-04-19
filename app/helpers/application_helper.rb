module ApplicationHelper
  def country_flag(country_code)
    return nil if country_code.blank?
    country_code.upcase.chars.map { |c| (c.ord + 0x1F1A5).chr(Encoding::UTF_8) }.join
  end
end
