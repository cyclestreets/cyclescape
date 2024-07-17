# frozen_string_literal: true

class IssuesController < ApplicationController
  include MessageCreator
  include IssueFeature

  filter_access_to %i[edit update destroy], attribute_check: true
  protect_from_forgery except: :vote_detail

  def index
    issues = Issue.preloaded.by_most_recent.page(params[:page])

    popular_issues = Issue.preloaded.by_score.page(params[:pop_issues_page])

    @issues = IssueDecorator.decorate_collection issues
    @popular_issues = IssueDecorator.decorate_collection popular_issues
    @start_location = index_start_location
  end

  def show
    redirect_to issue_url(issue) unless request.original_url.end_with?(issue_path(issue))

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
    return permission_denied unless current_user.approved?

    issue_params = permitted_params.merge(created_by: current_user)
    # Something is buggy, Issue.new(photo: "", retained_photo: "") complains the photo isn't valid
    issue_params.delete(:photo) if issue_params[:photo].blank?
    issue_params.delete(:retained_photo) if issue_params[:retained_photo].blank?

    @issue = current_user.issues.new issue_params
    thread = @issue.threads.last
    if thread
      thread.tags = @issue.tags
      thread.created_by = current_user
      @message = create_message(thread)
    end

    if @issue.save
      NewIssueNotifier.new_issue @issue
      if issue.start_discussion
        redirect_on_check_reason(@message, spam_path: issue_path(issue), clean_path: thread_path(thread))
      else
        redirect_to issue_path(issue)
      end
    else
      new_issue_setup
      render :new
    end
  end

  def edit
    @issue.description = helpers.simple_format(@issue.description) if @issue.plain_text?
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
    issues = issues.with_center_inside(bbox.to_geometry) if bbox

    # TODO: refactor this into decorater
    decorated_issues = issues.select_area.sort_by(&:area).map { |issue| issue_feature(IssueDecorator.decorate(issue), bbox) }
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
    issues = Issue.where(id: params[:ids])
    render partial: "shared/vote_detail", collection: issues, as: :resource
  end

  protected

  def new_issue_setup
    @start_location ||= current_user.start_location
    thread = @issue.threads.first || @issue.threads.build(group: current_group)
    @message ||= thread.messages.build
  end

  def geom_issue_scope
    Issue
  end

  def index_start_location
    if centered_issue = Issue.find_by(id: params[:issue_id])
      return centered_issue.location
    end
    return current_user.start_location if current_user && current_user.start_location != SiteConfig.first.nowhere_location
    return current_group.start_location if current_group&.start_location
    return @issues.first.location unless @issues.empty?

    SiteConfig.first.nowhere_location
  end

  def issue
    @issue ||= Issue.find(params[:id])
  end

  def permitted_params
    params.require(:issue).permit :title, :photo, :retained_photo, :loc_json, :tags_string, :start_discussion,
                                  :description, :deadline, :all_day, :external_url, :planning_application_id, threads_attributes: %i[title group_id privacy]
  end
end
