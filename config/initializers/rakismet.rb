# frozen_string_literal: true

Cyclescape::Application.config.rakismet.key =
  if %w[development test].include? Rails.env
    "development"
  else
    ENV["AKISMET"]
  end

Cyclescape::Application.config.rakismet.url = "http://www.cyclescape.org/"
