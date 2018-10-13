require File.expand_path('../production', __FILE__)
Rails.application.configure do
  config.action_mailer.show_previews = true
end
