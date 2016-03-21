class TagsController < ApplicationController
  autocomplete :tag, :name, full: true

  def show
    @tag = Tag.find_by_name params[:id]
    if @tag
      @query = @tag.name
      issues = Issue.find_by_tag(@tag).order('updated_at desc').page(params[:issue_page])
      @issues = IssueDecorator.decorate_collection issues
      unfiltered_results = MessageThread.find_by_tag(@tag).order('updated_at desc')
      threads = Kaminari.paginate_array(
        unfiltered_results.select{ |t| permitted_to?(:show, t) }).page(params[:thread_page])

      @threads = ThreadListDecorator.decorate_collection threads
      @library_items = Library::Item.find_by_tag(@tag).order('updated_at desc').page(params[:library_page])
    else
      @unrecognised_tag_name = params[:id]
    end
  end
end
