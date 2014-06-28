require 'action_mailer'

# TODO : add mailer logger

ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
   :address   => "smtp.mandrillapp.com",
   :port      => 587,
   # :domain    => "squareteam.io",
   :authentication => :plain,
   :user_name      => "cpoly55+st@gmail.com",
   :password       => "a4vPWv_HNATqdh18cjybMw",
   :enable_starttls_auto => true
}
ActionMailer::Base.view_paths= File.expand_path('../../../app/views', __FILE__)