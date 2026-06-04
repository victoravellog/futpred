MetaTags.configure do |config|
  config.title_limit = 70
  config.description_limit = 160
  config.truncate_site_title_first = false
end

module MetaTagsDefaults
  extend ActiveSupport::Concern

  included do
    before_action :set_default_meta_tags
  end

  private

  def set_default_meta_tags
    defaults = I18n.t("meta_tags.#{controller_name}.#{action_name}", default: {})
    return if defaults.blank?

    meta = { title: defaults[:title], description: defaults[:description] }

    if defaults[:title].present?
      meta[:og] = {
        title: "#{defaults[:title]} — FutPred",
        description: defaults[:description],
        image: "#{request.base_url}/icon.png",
        url: request.original_url
      }
    end

    set_meta_tags(meta)
  end
end
