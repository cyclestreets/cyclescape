class GroupsController < ApplicationController
  def index
    groups = Group.paginate(page: params[:page])

    @groups = GroupDecorator.decorate(groups)
    @start_location = index_start_location
  end

  def show
    if params[:id]
      @group = Group.find(params[:id])
    elsif current_group
      @group = current_group
    end

    if @group
      @group = GroupDecorator.decorate(@group)
      if @group.has_member?(current_user)
        recent_threads = ThreadList.recent_from_groups(@group, 10).includes(:issue, :group)
      else
        recent_threads = ThreadList.recent_public_from_groups(@group, 10).includes(:issue, :group)
      end
      @recent_threads = ThreadListDecorator.decorate(recent_threads)
      @recent_issues = IssueDecorator.decorate(@group.recent_issues.limit(10).includes(:created_by))
    else
      redirect_to root_url(subdomain: 'www')
    end
  end

  def all_geometries
    if params[:bbox]
      bbox = bbox_from_string(params[:bbox], GroupProfile.rgeo_factory)
      group_profiles = GroupProfile.intersects(bbox.to_geometry).order("created_at DESC").limit(50)
    else
      bbox = nil
      group_profiles = GroupProfile.order("created_at DESC").limit(50)
    end
    factory = RGeo::GeoJSON::EntityFactory.new
    collection = factory.feature_collection(group_profiles.sort_by!{|o| o.size}.reverse.map { | group_profile | group_feature(GroupDecorator.decorate(group_profile.group), bbox) })
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(collection)}
    end
  end

  private

  def index_start_location
    return current_user.start_location if current_user && current_user.start_location != Geo::NOWHERE_IN_PARTICULAR
    return current_group.start_location if current_group && current_group.start_location
    return Geo::NOWHERE_IN_PARTICULAR
  end

  def group_feature(group, bbox = nil)
    geom = bbox.to_geometry if bbox

    group.loc_feature( # thumbnail: group.medium_icon_path,
                        # image_url: issue.tip_icon_path(false),
                        title: group.name,
                        # size_ratio: group.size_ratio(geom),
                        # url: view_context.url_for(group.profile),
                        url: root_url(subdomain: group.short_name),
                        description: view_context.auto_link(group.trunctated_description))
  end
end
