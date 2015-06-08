class Library::TagsController < ApplicationController
  def update
    @item = Library::Item.find params[:id]
    if @item.update_attribute(:tags_string, params[:library_item][:tags_string])
      render json: { tagspanel: TagPanelDecorator.new(@item, form_url: url_for, auth_context: :library_tags).render }
    else
      head :conflict
    end
  end
end
