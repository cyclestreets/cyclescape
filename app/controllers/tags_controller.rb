class TagsController < ApplicationController
  autocomplete :tag, :name, full: true

  def show
    @tag = Tag.find_by_name(params[:id])
    if @tag
      @issues = Issue.find_by_tag(@tag).order('updated_at desc').limit(20)
      # Threads - argh, privacy!
      threads = MessageThread.public.find_by_tag(@tag).order('updated_at desc').limit(20)
      @threads = ThreadListDecorator.decorate(threads)
      @library_items = Library::Item.find_by_tag(@tag).order('updated_at desc').limit(20)
    else
      @unrecognised_tag_name = params[:id]
    end
  end
end
