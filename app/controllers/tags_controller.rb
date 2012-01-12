class TagsController < ApplicationController
  def show
    @tag = Tag.find_by_name(params[:id])
    @issues = Issue.find_by_tag(@tag).order("updated_at desc").limit(20)
    # Threads - argh, privacy!
    @threads = MessageThread.public.find_by_tag(@tag).order("updated_at desc").limit(20)
    @library_items = Library::Item.find_by_tag(@tag).order("updated_at desc").limit(20)
  end
end
