class GroupsController < ApplicationController
  def index
    groups = Group.page params[:page]

    @groups = GroupDecorator.decorate_collection groups
    @start_location = index_start_location
  end

  def show
    if group
      if @group.has_member?(current_user)
        recent_threads = ThreadList.recent_from_groups(group, 10).includes(:issue, :group)
      else
        recent_threads = ThreadList.recent_public_from_groups(group, 10).includes(:issue, :group)
      end
      @recent_threads = ThreadListDecorator.decorate_collection recent_threads
      @recent_issues = IssueDecorator.decorate_collection group.recent_issues.limit(10).includes(:created_by)
      @group = GroupDecorator.decorate group
    else
      redirect_to root_url(subdomain: 'www')
    end
  end

  def all_geometries
    if params[:bbox]
      bbox = bbox_from_string(params[:bbox], GroupProfile.rgeo_factory)
      group_profiles = GroupProfile.intersects(bbox.to_geometry).order('created_at DESC').limit(50)
    else
      bbox = nil
      group_profiles = GroupProfile.order('created_at DESC').limit(50)
    end
    factory = RGeo::GeoJSON::EntityFactory.new
    collection = factory.feature_collection(group_profiles.sort_by { |o| o.size }.reverse.map { | group_profile | group_feature(GroupDecorator.decorate(group_profile.group), bbox) })
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(collection) }
    end
  end

  def search
    @query = params[:query]
    set_page_title t('.title', group: group.name)

    threads = MessageThread.search do
      fulltext params[:query] do
        boost_fields title: 2.0
      end
      with(:status, 'approved')
      with(:location).in_bounding_box(*group_bb)
      any_of do
        with(:privacy, 'public')
        if current_user
          all_of do
            with(:group_id, current_user.groups.try(:ids))
            with(:privacy, 'group')
          end
          all_of do
            with(:group_id, current_user.in_group_committee.try(:ids))
            with(:privacy, 'committee')
          end
        end
      end
      paginate page: params[:thread_page], per_page: 50
    end
    @threads = ThreadListDecorator.decorate_collection threads.results

    # Issues
    issues = Issue.search do
      fulltext params[:query] do
        boost_fields title: 2.0
      end
      with(:location).in_bounding_box(*group_bb)
      paginate page: params[:issue_page], per_page: 50
    end
    @issues = IssueDecorator.decorate_collection issues.results

    # Library Items
    library_items = Library::Item.search do
      fulltext params[:query]
      paginate page: params[:library_page], per_page: 50
    end
    @library_items = Library::ItemDecorator.decorate_collection library_items.results
  end

  private

  def group
    @group ||= if params[:id]
                 Group.find params[:id]
               elsif current_group
                 current_group
               end
  end

  def index_start_location
    return current_user.start_location if current_user && current_user.start_location != Geo::NOWHERE_IN_PARTICULAR
    return current_group.start_location if current_group && current_group.start_location
    return Geo::NOWHERE_IN_PARTICULAR
  end

  def group_feature(group, bbox = nil)
    geom = bbox.to_geometry if bbox

    group.loc_feature(title: group.name,
                      size_ratio: group.profile.size_ratio(geom),
                      url: root_url(subdomain: group.short_name),
                      description: view_context.auto_link(group.trunctated_description))
  end

  def group_bb
    @group_bb ||= begin
                    bb = RGeo::Cartesian::BoundingBox.create_from_geometry group.profile.location
                    [[bb.min_y, bb.min_x], [bb.max_y, bb.max_x]]
                  end
  end

end
