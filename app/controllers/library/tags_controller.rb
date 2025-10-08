# frozen_string_literal: true

class Library::TagsController < BaseTagsController
  private

  def resource
    @resource ||= Library::Item.find params[:id]
  end
end
