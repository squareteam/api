require 'action_mailer'
require 'inline-style'

# TODO : add mailer logger
Squareteam::Application.configure do |config|
  base = ActionMailer::Base
  # Default options to REMOVE from here
  base.raise_delivery_errors = true
  base.delivery_method = :smtp
  base.smtp_settings = {
    :address   => "smtp.mandrillapp.com",
    :port      => 587,
    # :domain    => "squareteam.io",
    :authentication => :plain,
    :user_name      => "cpoly55+st@gmail.com",
    :password       => "a4vPWv_HNATqdh18cjybMw",
    :enable_starttls_auto => true
  }
  base.view_paths = File.expand_path('../../../app/views', __FILE__)
  # Use following config via *.yml
  # TODO: separate by RACK_ENV
  mailer = YAML.load(ERB.new(File.read(File.dirname(__FILE__) + "/../mailer.yml")).result).symbolize_keys
  mailer.each do |key, value|
    is_hash = value.respond_to? :symbolize_keys
    base.send("#{key}=", is_hash ? value.symbolize_keys : value)
  end
end

ActionMailer::Base.register_interceptor \
  InlineStyle::Mail::Interceptor.new(:stylesheets_path => File.expand_path('../../../public/stylesheets', __FILE__))
