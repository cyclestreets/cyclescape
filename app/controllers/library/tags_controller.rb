# frozen_string_literal: true

class Library::TagsController < ApplicationController
  def update
    @item = Library::Item.find params[:id]
    authorize @item, :update_tags?
    if @item.update tags_string: params[:library_item][:tags_string]
      render json: { tagspanel: TagPanelDecorator.new(@item, form_url: url_for).render }
    else
      head :conflict
    end
  end
end
