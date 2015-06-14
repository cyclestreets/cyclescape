# Note inheritance
class Group::IssuesController < IssuesController
  filter_access_to [:edit, :update, :destroy], attribute_check: true, context: :issues
  filter_access_to :all, context: :issues

  def index
    set_page_title t('group.issues.index.title', group_name: current_group.name)

    issues = Issue.intersects(current_group.profile.location).by_most_recent.paginate(page: params[:page])

    # work around till https://github.com/bouchard/thumbs_up/issues/64 is fixed
    popular_issue_ids = Issue.intersects(current_group.profile.location).plusminus_tally(start_at: 8.weeks.ago, at_least: 1).pluck :id
    popular_issues = Issue.where(id: popular_issue_ids).paginate(page: params[:pop_issues_page]).includes(:created_by)

    @issues = IssueDecorator.decorate_collection issues
    @popular_issues = IssueDecorator.decorate_collection popular_issues
    @start_location = index_start_location
  end

  def all_geometries
    if params[:bbox]
      bbox = bbox_from_string(params[:bbox], Issue.rgeo_factory)
      issues = Issue.intersects(current_group.profile.location).intersects_not_covered(bbox.to_geometry).order('created_at DESC').limit(50)
    else
      issues = Issue.intersects(current_group.profile.location).order('created_at DESC').limit(50)
    end
    factory = RGeo::GeoJSON::EntityFactory.new
    collection = factory.feature_collection(issues.map { | issue | issue_feature(IssueDecorator.decorate(issue)) })
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(collection) }
    end
  end
end
