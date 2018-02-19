Capybara.register_driver :poltergeist_local do |app|
  Capybara::Poltergeist::Driver.new(app, { url_whitelist: "http://127.0.0.1" })
end
Capybara.javascript_driver = :poltergeist_local
