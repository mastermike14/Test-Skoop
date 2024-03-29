# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  
  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
     
      
  #Config gems here
     config.gem 'will_paginate'
     config.gem 'twitter'
     config.gem 'rubyist-aasm', :lib => 'aasm', :source => 'http://gems.github.com'

	 
  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
 
  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'
  config.reload_plugins = true if RAILS_ENV == 'development'
  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de

config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  :address        => 'smtp.waukee.k12.ia.us',
  :port           => 25,
  :domain         => 'www.waukee.k12.ia.us',
  :authentication => :login,
  :user_name      => 'skloop',
  :password       => 'house79'
}

end
ConsumerConfig = YAML.load(File.read(Rails.root + 'config' + 'consumer.yml'))

