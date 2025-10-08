# frozen_string_literal: true

class BaseTagsController < ApplicationController
  def edit
    authorize resource, :update_tags?
    render turbo_stream: turbo_stream.replace(helpers.dom_id(resource, :tags), partial: "shared/edit_tags", locals: { resource: resource })
  end

  def update
    authorize resource, :update_tags?
    if resource.update tags_string: params[:resource][:tags_string]
      render turbo_stream: turbo_stream.replace(
        helpers.dom_id(resource, :tags),
        partial: "shared/tags/widget_content",
        locals: { resource: resource }
      )
    else
      head :conflict
    end
  end
end
