class ApplicationMailer < ActionMailer::Base
  default from: ENV['DEFAULT_EMAIL_USERNAME']
  layout "mailer"
end
