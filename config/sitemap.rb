SitemapGenerator::Sitemap.default_host = "https://futpred.com"
SitemapGenerator::Sitemap.compress = false
SitemapGenerator::Sitemap.public_path = "public/"
SitemapGenerator::Sitemap.sitemaps_path = ""

SitemapGenerator::Sitemap.create do
  # Landing page (both locales)
  add root_path, changefreq: "weekly", priority: 1.0
  add localized_root_path(locale: :es), changefreq: "weekly", priority: 1.0
  add localized_root_path(locale: :en), changefreq: "weekly", priority: 0.9

  # Public auth pages
  add new_session_path, changefreq: "monthly", priority: 0.5
  add new_registration_path, changefreq: "monthly", priority: 0.6
  add new_password_path, changefreq: "monthly", priority: 0.3

  # Pricing and contact (both locales)
  add pricing_path, changefreq: "monthly", priority: 0.8
  add pricing_path(locale: :es), changefreq: "monthly", priority: 0.8
  add pricing_path(locale: :en), changefreq: "monthly", priority: 0.7
  add contact_path, changefreq: "monthly", priority: 0.4
  add contact_path(locale: :es), changefreq: "monthly", priority: 0.4
  add contact_path(locale: :en), changefreq: "monthly", priority: 0.4

  # Legal pages
  add privacy_path, changefreq: "yearly", priority: 0.3
  add privacy_path(locale: :es), changefreq: "yearly", priority: 0.3
  add privacy_path(locale: :en), changefreq: "yearly", priority: 0.3
  add terms_path, changefreq: "yearly", priority: 0.3
  add terms_path(locale: :es), changefreq: "yearly", priority: 0.3
  add terms_path(locale: :en), changefreq: "yearly", priority: 0.3
end
