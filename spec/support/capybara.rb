# frozen_string_literal: true

Capybara.always_include_port = true
Capybara.server = :webrick
Capybara.register_driver :selenium_chrome_headless_wide do |app|
  version = Capybara::Selenium::Driver.load_selenium
  options_key = Capybara::Selenium::Driver::CAPS_VERSION.satisfied_by?(version) ? :capabilities : :options
  browser_options = Selenium::WebDriver::Chrome::Options.new.tap do |opts|
    opts.add_argument("--headless=new")
    opts.add_argument("--disable-gpu") if Gem.win_platform?
    # Workaround https://bugs.chromium.org/p/chromedriver/issues/detail?id=2650&q=load&sort=-id&colspec=ID%20Status%20Pri%20Owner%20Summary
    opts.add_argument("--disable-site-isolation-trials")

    # https://github.com/teamcapybara/capybara/issues/2796#issuecomment-2678172710
    opts.add_argument("disable-background-timer-throttling")
    opts.add_argument("disable-backgrounding-occluded-windows")
    opts.add_argument("disable-renderer-backgrounding")

    # Only line that is added from the default :selenium_chrome_headless
    opts.add_argument("--window-size=1001,800")
  end

  Capybara::Selenium::Driver.new(app, **{ :browser => :chrome, options_key => browser_options })
end
Capybara.javascript_driver = :selenium_chrome_headless_wide
