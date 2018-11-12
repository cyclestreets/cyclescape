# frozen_string_literal: true

class PagesController < ApplicationController
  def show
    template_name = 'pages/' + File.basename(params[:page].to_s)
    if template_exists? template_name
      render template: template_name
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
