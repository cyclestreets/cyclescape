# frozen_string_literal: true

module Admin
  class TemplatesController < BaseController
    def show
      template_name = "admin/templates/" + File.basename(params[:template].to_s)
      if template_exists? template_name
        render template: template_name
      else
        raise ActionController::RoutingError, "Not Found"
      end
    end
  end
end
