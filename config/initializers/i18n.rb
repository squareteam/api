app_path = File.expand_path('../../../.', __FILE__)
Dir.glob("#{app_path}/config/locales/*.yml") do |locale_file|
  I18n.load_path << locale_file.to_s
end
