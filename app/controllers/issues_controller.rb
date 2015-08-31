class IssuesController < ApplicationController
  filter_access_to [:edit, :update, :destroy], attribute_check: true

  def index
    issues = Issue.by_most_recent.paginate(page: params[:page]).includes(:created_by)

    # work around till https://github.com/bouchard/thumbs_up/issues/64 is fixed
    popular_issue_ids = Issue.plusminus_tally(start_at: 8.weeks.ago, at_least: 1).map &:id
    popular_issues = Issue.where(id: popular_issue_ids).paginate(page: params[:pop_issues_page]).includes(:created_by)

    @issues = IssueDecorator.decorate_collection issues
    @popular_issues = IssueDecorator.decorate_collection popular_issues
    @start_location = index_start_location
  end

  def show
    @issue = IssueDecorator.decorate issue
    set_page_title @issue.title
    @threads = ThreadListDecorator.decorate_collection @issue.threads.order_by_latest_message.includes(:group)
    @tag_panel = TagPanelDecorator.new(@issue, form_url: issue_tags_path(@issue), cancel_url: issue_path(@issue))
  end

  def new
    @issue = Issue.new
    @start_location = current_user.start_location
  end

  def create
    @issue = current_user.issues.new permitted_params

    if @issue.save
      NewIssueNotifier.new_issue @issue
      redirect_to new_issue_thread_path @issue
    else
      @start_location = current_user.start_location
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
    issues = Issue.order('created_at DESC').limit(50)
    issues = issues.intersects_not_covered(bbox.to_geometry) if bbox

    # TODO refactor this into decorater
    decorated_issues = issues.order('ST_Area(location) DESC').map { | issue | issue_feature(IssueDecorator.decorate(issue), bbox) }
    collection = RGeo::GeoJSON::EntityFactory.new.feature_collection(decorated_issues)
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(collection) }
    end
  end

  def vote_up
    if current_user.voted_for? issue
      set_flash_message :already
    else
      current_user.vote_exclusively_for issue
      set_flash_message :success
    end
    redirect_to issue
  end

  def vote_down
    if current_user.voted_against? issue
      set_flash_message :already
    else
      current_user.vote_exclusively_against issue
      set_flash_message :success
    end
    redirect_to issue
  end

  def vote_clear
    if current_user.clear_votes issue
      set_flash_message :success
    else
      set_flash_message :failure
    end
    redirect_to issue
  end

  protected

  def index_start_location
    return current_user.start_location if current_user && current_user.start_location != Geo::NOWHERE_IN_PARTICULAR
    return current_group.start_location if current_group && current_group.start_location
    return @issues.first.location unless @issues.empty?
    return Geo::NOWHERE_IN_PARTICULAR
  end

  def issue_feature(issue, bbox = nil)
    geom = bbox.to_geometry if bbox
    creator_name = if permitted_to? :view_profile, issue.created_by
                     issue.created_by.name
                   else
                     issue.created_by.display_name_or_anon
                   end
    issue.loc_feature(thumbnail: issue.medium_icon_path,
                      image_url: issue.tip_icon_path(false),
                      title: issue.title,
                      size_ratio: issue.size_ratio(geom),
                      url: view_context.url_for(issue),
                      created_by: creator_name,
                      created_by_url: view_context.url_for(issue.created_by))
  end

  def issue
    @issue ||= Issue.find(params[:id])
  end

  def permitted_params
    params.require(:issue).permit :title, :photo, :retained_photo, :loc_json, :tags_string,
      :description, :deadline, :external_url
  end
end
