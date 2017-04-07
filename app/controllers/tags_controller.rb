class TagsController < ApplicationController
  autocomplete :tag, :name, full: true

  def show
    @tag = Tag.find_by name: params[:id]
    if @tag
      @query = @tag.name
      issues = Issue.find_by_tag(@tag).order(updated_at: :desc).page(params[:issue_page])
      issues = issues.intersects(current_group.profile.location) if current_group
      @issues = IssueDecorator.decorate_collection issues
      unfiltered_results = MessageThread.find_by_tag(@tag).includes(:issue, :group).order(updated_at: :desc)
      threads = Kaminari.paginate_array(
        unfiltered_results.select{ |t| permitted_to?(:show, t) }
      ).page(params[:thread_page])

      @threads = ThreadListDecorator.decorate_collection threads
      @unviewed_thread_ids = MessageThread.unviewed_thread_ids(user: current_user, threads: threads)

      @library_items = Library::Item.find_by_tag(@tag).order('updated_at desc').page(params[:library_page])
    else
      @unrecognised_tag_name = params[:id]
    end
  end

  def index
    Tag.top_tags(200)
  end
end
