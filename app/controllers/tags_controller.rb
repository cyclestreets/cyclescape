class TagsController < ApplicationController
  def show
    @tag = Tag.find_by_name(params[:id])
    @issues = Issue.find_by_tag(@tag)

    # Threads - argh, privacy!
    @threads = MessageThread.public.find_by_tag(@tag)
    @library_items = Library::Item.find_by_tag(@tag)
  end
end
