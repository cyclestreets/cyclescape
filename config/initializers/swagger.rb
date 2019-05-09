# frozen_string_literal: true

GrapeSwaggerRails.options.url = "/api/swagger_doc"

GrapeSwaggerRails.options.app_name = "Cyclescape API"
GrapeSwaggerRails.options.api_key_type = "query"
GrapeSwaggerRails.options.before_action do
  GrapeSwaggerRails.options.app_url = request.protocol + request.host_with_port
  GrapeSwaggerRails.options.api_key_default_value = current_user&.api_key
end
