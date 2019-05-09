# frozen_string_literal: true

class Admin::TemplatesController < ApplicationController
  def show
    template_name = "admin/templates/" + File.basename(params[:template].to_s)
    if template_exists? template_name
      render template: template_name
    else
      raise ActionController::RoutingError, "Not Found"
    end
  end
end
