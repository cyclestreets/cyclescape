# frozen_string_literal: true

akismet_file = Rails.root.join("config", "akismet")

Cyclescape::Application.config.rakismet.key =
  if (token = Rails.application.credentials.rakismet)
    token
  elsif %w[development test].include? Rails.env
    "development"
  end

Cyclescape::Application.config.rakismet.url = "https://www.cyclescape.org/"
