class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM_ADDRESS", "Fieldnotes <no-reply@fieldnotes.local>")
  layout "mailer"
end
