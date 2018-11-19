# frozen_string_literal: true

require 'grape-swagger-rails'

class Api < Grape::API
  include Grape::Kaminari

  version 'v1', using: :accept_version_header
  format :json # We have used `.as_json` to control the exposed response so add formats carefully.
  prefix :api

  mount Route::ThreadApi
  mount Route::MessageApi
  mount Route::IssueApi
  mount Route::GroupApi
  mount Route::TagApi
  mount Route::ConstituencyApi
  mount Route::WardApi
  mount Route::MembershipApi

  add_swagger_documentation \
    info: {
    title: "Cyclescape's JSON API",
    description: "This is a public API and this page provides a test requests and it provides responses.",
  },
  security_definitions: {
    api_key: {
      type: "apiKey",
      name: "api_key",
      in: "params"
    }
  }
end
