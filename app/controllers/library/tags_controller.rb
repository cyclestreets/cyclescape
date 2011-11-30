class Library::TagsController < ApplicationController
  def update
    @item = Library::Item.find(params[:id])
    if @item.update_attributes(tags_string: params[:library_item][:tags_string])
      render text: TagPanelDecorator.new(@item, form_url: url_for).render
    else
      head :conflict
    end
  end
end
