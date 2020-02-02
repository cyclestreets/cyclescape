# frozen_string_literal: true

Capybara.always_include_port = true
Capybara.server = :webrick
Capybara.javascript_driver = :selenium_chrome_headless
