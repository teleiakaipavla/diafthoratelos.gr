require 'magent/web_socket_channel'

Rails.application.config.session_options[:domain] = ".#{AppConfig.domain}"
Rails.application.config.session_options[:key] = AppConfig.session_key
Rails.application.config.secret_token = AppConfig.session_secret

AppConfig.enable_facebook_auth = AppConfig.facebook["activate"]

AppConfig.version = File.read(Rails.root + "VERSION")

if AppConfig.smtp["activate"]
  ActionMailer::Base.smtp_settings = {
    :address => AppConfig.smtp["server"],
    :port => AppConfig.smtp["port"],
    :domain => AppConfig.smtp["domain"],
    :authentication => :login,
    :user_name => AppConfig.smtp["login"],
    :password => AppConfig.smtp["password"]
  }
end

share_links = File.open( 'config/share_links.yml' ) { |yf| YAML::load( yf ) }

AppConfig.share_links = share_links[Rails.env]

if Rails.env == "development" || ENV['debug_assets']
  MODERNIZR = :modernizrdev
else
  MODERNIZR = 'modernizr_7'
end
