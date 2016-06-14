require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env)

module VoicesRails
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Add bootstrap fonts to the asset path (see also static_pages.css.scss, which overrides bootstrap's
    # default path for requested glyphicon assets in order to point to the asset_path())
    config.assets.enabled = true

    # recursively add font elements to asset path
    Dir.glob("#{Rails.root}/vendor/assets/fonts/**").each do |path|
      config.assets.paths << path
    end


    # One can now to reference glyphicons/glyphicons-halflings-regular.woff; see
    # static_pages.css.scss for the implementation there

    # Raise errors caused during after_rollback and after_commit
    config.active_record.raise_in_transactional_callbacks = true

    # Add assets in all subdirectories of images to asset pipeline
    Dir.glob("#{Rails.root}/app/assets/images/**/").each do |path|
      config.assets.paths << path
    end

    # use rack cors to provide cors headers
    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :options]
      end
    end

  end
end