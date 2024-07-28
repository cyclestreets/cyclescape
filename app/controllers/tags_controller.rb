# frozen_string_literal: true

class TagsController < ApplicationController
  include IssueFeature


  def autocomplete_tag_name
    skip_authorization

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
    skip_authorization

    @tag = Tag.find_by name: params[:id]
    if @tag
      @query = @tag.name
      issues = Issue.find_by_tag(@tag).order(updated_at: :desc).page(params[:issue_page])
      issues = issues.intersects(current_group.profile.location) if current_group
      bbox = RGeo::Cartesian::BoundingBox.new(RGeo::Geographic.spherical_factory(srid: 4326))
      issues.each { |iss| bbox.add(iss.location) }
      @start_location = { fitBounds: [[bbox.min_y, bbox.min_x], [bbox.max_y, bbox.max_x]] }.to_json

      @issues = IssueDecorator.decorate_collection issues
      unfiltered_results = MessageThread.find_by_tag(@tag).includes(:issue, :group).order(updated_at: :desc)
      threads = Kaminari.paginate_array(
        unfiltered_results.select { |t| MessageThreadPolicy.new(current_user, t).show? }
      ).page(params[:thread_page])

      @threads = ThreadListDecorator.decorate_collection threads
      @unviewed_thread_ids = MessageThread.unviewed_thread_ids(user: current_user, threads: threads)

      @library_items = Library::Item.find_by_tag(@tag).order("updated_at desc").page(params[:library_page])
      planning_applications = PlanningApplication.search(params[:query])
                                                 .includes(:users, :issue)
                                                 .page params[:planning_page]
      @planning_applications = PlanningApplicationDecorator.decorate_collection planning_applications
      @full_page = true
    else
      @unrecognised_tag_name = params[:id]
    end
  end

  def index
    skip_authorization

    @tags = Tag.top_tags(200)
  end

  def all_geometries
    skip_authorization

    tag = Tag.find_by name: params[:id]
    bbox = bbox_from_string(params[:bbox], Issue.rgeo_factory)
    issues = Issue.find_by_tag(tag).by_most_recent
    issues = issues.intersects(current_group.profile.location) if current_group
    issues = issues.with_center_inside(bbox.to_geometry) if bbox

    # TODO: refactor this into decorater
    decorated_issues = issues.select_area.order(:area).map { |issue| issue_feature(IssueDecorator.decorate(issue), bbox) }
    collection = RGeo::GeoJSON::EntityFactory.new.feature_collection(decorated_issues)
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(collection) }
    end
  end
end
