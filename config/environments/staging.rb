# frozen_string_literal: true

require File.expand_path("production", __dir__)
Rails.application.configure do
  config.action_mailer.show_previews = true
end
