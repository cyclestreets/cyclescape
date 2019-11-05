# frozen_string_literal: true

class TagsController < ApplicationController
  def autocomplete_tag_name
    term = params[:term]

    items =
      if term&.present?
        Tag.top_tags_fresh(5, term).map do |tag|
          { id: tag.id, label: tag.autocomplete_tag_name, value: tag.name }
        end
      else
        []
      end

    render json: items, root: false
  end

  def show
    @tag = Tag.find_by name: params[:id]
    if @tag
      @query = @tag.name
      issues = Issue.find_by_tag(@tag).order(updated_at: :desc).page(params[:issue_page])
      issues = issues.intersects(current_group.profile.location) if current_group
      @issues = IssueDecorator.decorate_collection issues
      unfiltered_results = MessageThread.find_by_tag(@tag).includes(:issue, :group).order(updated_at: :desc)
      threads = Kaminari.paginate_array(
        unfiltered_results.select { |t| permitted_to?(:show, t) }
      ).page(params[:thread_page])

      @threads = ThreadListDecorator.decorate_collection threads
      @unviewed_thread_ids = MessageThread.unviewed_thread_ids(user: current_user, threads: threads)

      @library_items = Library::Item.find_by_tag(@tag).order("updated_at desc").page(params[:library_page])
      planning_applications = PlanningApplication.search(params[:query])
                                                 .includes(:users, :issue)
                                                 .page params[:planning_page]
      @planning_applications = PlanningApplicationDecorator.decorate_collection planning_applications

    else
      @unrecognised_tag_name = params[:id]
    end
  end

  def index
    @tags = Tag.top_tags(200)
  end
end
