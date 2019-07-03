# frozen_string_literal: true

WebMock.enable!
WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: "chromedriver.storage.googleapis.com"
)
