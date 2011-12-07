class LibrariesController < ApplicationController
  def show
    @recent_documents = Library::Document.recent(5)
    @recent_notes = Library::Note.recent(5)
  end

  def search
    s = params[:search]
    @query = s[:query]
    @results = Library::Item.find_with_index(@query)
  end
end
