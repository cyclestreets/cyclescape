class LibrariesController < ApplicationController
  def show
    @items = Library::ItemDecorator.decorate(Library::Item.by_most_recent.page(params[:page]))
  end

  def search
    s = params[:search]
    @query = s[:query]
    @results = Library::Item.find_with_index(@query)
  end
end
