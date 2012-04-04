# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.7' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')  

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'Berlin'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
  
  #Rubygems needs to be downgraded to 1.4.2
  #config.gem 'rubygems-update', :version => "1.4.2"  
  
  #config.gem 'ruby-graphviz', :version => "1.0.5"  
  config.gem 'whenever', :version => "0.7.3", :lib => false, :source => 'http://gems.github.com'
  config.gem 'will_paginate', :version => "2.2.2", :lib => 'will_paginate', :source => 'http://gems.github.com'
  config.gem 'grackle', :version => "0.1.10"
  config.gem 'twitter', :version => "1.7.2"
  config.gem 'ruby-debug', :version => "0.10.4"
  config.gem 'chronic', :version => "0.6.7"
  config.gem 'gnuplot', :version => "2.3.6"
  config.gem 'typhoeus', :version => "0.3.3"
  config.gem 'ar-extensions', :version => "0.9.5"
  config.gem 'simple-rss', :version => "1.2.3"  
  config.gem 'mongrel', :version => "1.1.5"
  config.gem 'mysql', :version => "2.8.1"
  config.gem "daemons", :version => "1.0.10" # delayed job needs this
  config.gem "delayed_job", :version => "2.0.7"
  config.gem "scrapi", :version => "1.2.0"
  config.gem "tidy_ffi"

  #Install for testing
  #config.gem 'factory_girl', :version => "1.3.3"
  #config.gem 'rspec-rails', :version => '1.3.2'
  #config.gem 'rspec', :version => "1.3.2"
  
end


