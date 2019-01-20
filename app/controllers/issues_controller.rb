# frozen_string_literal: true

class IssuesController < ApplicationController
  include MessageCreator

  filter_access_to [:edit, :update, :destroy], attribute_check: true
  protect_from_forgery except: :vote_detail

  def index
    issues = Issue.preloaded.by_most_recent.page(params[:page])

    popular_issues = Issue.preloaded.by_score.page(params[:pop_issues_page])

    @issues = IssueDecorator.decorate_collection issues
    @popular_issues = IssueDecorator.decorate_collection popular_issues
    @start_location = index_start_location
  end

  def show
    unless request.original_url.end_with?(issue_path(issue))
      redirect_to issue_url(issue)
    end

    @issue = IssueDecorator.decorate issue
    set_page_title @issue.title
    set_page_description @issue.description
    set_page_image @issue.photo.try(:url)
    @threads = ThreadListDecorator.decorate_collection @issue.threads.approved.order_by_latest_message.includes(:group)
    @tag_panel = TagPanelDecorator.new(@issue, form_url: issue_tags_path(@issue), cancel_url: issue_path(@issue))
  end

  def new
    @issue = Issue.new
    new_issue_setup
  end

  def create
    issue_params = permitted_params.merge(created_by: current_user)
    # Something is buggy, Issue.new(photo: "", retained_photo: "") complains the photo isn't valid
    issue_params.delete(:photo) unless issue_params[:photo].present?
    issue_params.delete(:retained_photo) unless issue_params[:retained_photo].present?

    @issue = current_user.issues.new issue_params
    thread = @issue.threads.last
    if thread
      thread.tags = @issue.tags
      thread.created_by = current_user
      @message = create_message(thread)
    end

    if @issue.save
      NewIssueNotifier.new_issue @issue
      redirect_on_check_reason(@message, spam_path: issue_path(issue), clean_path: thread_path(thread))
    else
      new_issue_setup
      render :new
    end
  end

  def edit
    @start_location = issue.location
  end

  def update
    if issue.update permitted_params
      set_flash_message :success
      redirect_to action: :show
    else
      @start_location = current_user.start_location
      render :edit
    end
  end

  def destroy
    if issue.destroy
      set_flash_message :success
      redirect_to issues_path
    else
      set_flash_message :failure
      redirect_to issue
    end
  end

  def geometry
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(issue_feature(IssueDecorator.decorate(issue))) }
    end
  end

  def all_geometries
    bbox = bbox_from_string(params[:bbox], Issue.rgeo_factory)
    issues = geom_issue_scope.by_most_recent.limit(50).includes(:created_by)
    issues = issues.intersects_not_covered(bbox.to_geometry) if bbox

    # TODO refactor this into decorater
    decorated_issues = issues.select_area.sort_by(&:area).map { | issue | issue_feature(IssueDecorator.decorate(issue), bbox) }
    collection = RGeo::GeoJSON::EntityFactory.new.feature_collection(decorated_issues)
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(collection) }
    end
  end

  def vote_up
    current_user.vote_exclusively_for(issue) unless current_user.voted_for?(issue)
    render partial: "shared/vote_detail", locals: { resource: @issue }
  end

  def vote_clear
    current_user.clear_votes issue
    render partial: "shared/vote_detail", locals: { resource: @issue }
  end

  def vote_detail
    render partial: "shared/vote_detail", locals: { resource: issue }
  end

  protected

  def new_issue_setup
    @start_location = current_user.start_location
    thread = @issue.threads.first || @issue.threads.build
    @message ||= thread.messages.build
    @available_groups = current_user.groups
  end

  def geom_issue_scope
    Issue
  end

  def index_start_location
    if centered_issue = Issue.find_by(id: params[:issue_id])
      return centered_issue.location
    end
    return current_user.start_location if current_user && current_user.start_location != SiteConfig.first.nowhere_location
    return current_group.start_location if current_group && current_group.start_location
    return @issues.first.location unless @issues.empty?
    return SiteConfig.first.nowhere_location
  end

  def issue_feature(issue, bbox = nil)
    geom = bbox.to_geometry if bbox
    creator_name = if permitted_to? :view_profile, issue.created_by
                     issue.created_by.name
                   else
                     issue.created_by.display_name_or_anon
                   end
    creator_url = if permitted_to? :view_profile, issue.created_by
                    view_context.url_for user_profile_path(issue.created_by)
                  else
                    '#'
                  end

    issue.loc_feature(thumbnail: issue.medium_icon_path,
                      anchor: issue.medium_icon_anchor,
                      image_url: issue.tip_icon_path,
                      title: issue.title,
                      size_ratio: issue.size_ratio(geom),
                      url: view_context.url_for(issue),
                      created_by: creator_name,
                      created_by_url: creator_url)
  end

  def issue
    @issue ||= Issue.find(params[:id])
  end

  def permitted_params
    params.require(:issue).permit :title, :photo, :retained_photo, :loc_json, :tags_string,
      :description, :deadline, :all_day, :external_url, :planning_application_id, threads_attributes: [:title, :group_id, :privacy]
  end
end
