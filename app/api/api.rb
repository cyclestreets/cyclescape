require 'grape-swagger-rails'

class Api < Grape::API
  include Grape::Kaminari

  version 'v1', using: :accept_version_header
  default_format :json
  prefix :api

  mount Route::IssueApi
  mount Route::GroupApi
  mount Route::TagApi
  mount Route::ConstituencyApi
  mount Route::WardApi

  add_swagger_documentation
end
