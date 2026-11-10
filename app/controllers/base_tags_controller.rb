# frozen_string_literal: true

class BaseTagsController < ApplicationController
  def edit
    authorize resource, :update_tags?
    render partial: "shared/edit_tags", locals: { resource: resource }
  end

  def update
    authorize resource, :update_tags?
    if resource.update tags_string: params[:resource][:tags_string]
      render partial: "shared/tags/widget_content", locals: { resource: resource }
    else
      render partial: "shared/edit_tags", locals: { resource: resource }, status: :unprocessable_entity
    end
  end
end
