# frozen_string_literal: true

Capybara.default_host = "http://localhost"
Capybara.always_include_port = true

Capybara.server = :webrick
Capybara.javascript_driver = :selenium_chrome_headless
