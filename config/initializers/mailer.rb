require 'action_mailer'
require 'inline-style'

# TODO : add mailer logger
mailer = ActionMailer::Base
mailer.raise_delivery_errors = true
mailer.delivery_method = :smtp
mailer.perform_deliveries = false
mailer.view_paths = File.expand_path('../../../app/views', __FILE__)
config = YAML.load(ERB.new(File.read(File.dirname(__FILE__) + "/../mailer.yml")).result)[Squareteam::Application.environment]
config.each do |key, value|
  is_hash = value.respond_to? :symbolize_keys
  mailer.send("#{key}=", is_hash ? value.symbolize_keys : value)
end

ActionMailer::Base.register_interceptor \
  InlineStyle::Mail::Interceptor.new(:stylesheets_path => File.expand_path('../../../public/stylesheets', __FILE__))
