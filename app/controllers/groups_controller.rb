# frozen_string_literal: true

class GroupsController < ApplicationController
  def index
    skip_authorization
    groups = Group.ordered.enabled

    respond_to do |format|
      format.html do
        groups = groups.page params[:page]
        @groups = GroupDecorator.decorate_collection groups
        @start_location = index_start_location
      end

      format.js do
        @groups = groups.from_geo_or_name params["homepage-find"]
      end
    end
  end

  def show
    skip_authorization

    if group
      recent_threads = if @group.has_member?(current_user)
                         ThreadList.recent_from_groups(group, 10)
                       else
                         ThreadList.recent_public_from_groups(group, 10)
                       end
      @recent_threads = ThreadListDecorator.decorate_collection recent_threads.includes(:issue, :group, :latest_message)
      @user_favourites = current_user&.thread_favourites&.where(thread: recent_threads)
      @unviewed_thread_ids = MessageThread.unviewed_thread_ids(user: current_user, threads: recent_threads)
      @recent_issues = IssueDecorator.decorate_collection group.recent_issues.limit(10).includes(:created_by)
      @group = GroupDecorator.decorate group
    else
      redirect_to root_url(subdomain: SubdomainConstraint.subdomain("www"))
    end
  end

  def all_geometries
    skip_authorization

    if params[:bbox]
      bbox = bbox_from_string(params[:bbox], GroupProfile.rgeo_factory)
      group_profiles = GroupProfile.intersects(bbox.to_geometry)
    else
      bbox = nil
      group_profiles = GroupProfile.all
    end
    group_profiles = group_profiles.enabled.with_location.ordered_by_size.limit(50)
    factory = RGeo::GeoJSON::EntityFactory.new
    collection = factory.feature_collection(group_profiles.map { |group_profile| group_feature(GroupDecorator.decorate(group_profile.group), bbox) })
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(collection) }
    end
  end

  def search
    skip_authorization

    @query = params[:query]
    set_page_title t(".title", group: group.name)
    _group = group

    threads = MessageThread.search(include: [:group, :issue, messages: :created_by]) do
      fulltext params[:query] do
        boost_fields title: 2.0
        boost_fields tags_string: 1.0
      end
      with(:status, "approved")
      any_of do
        with(:location).in_bounding_box(*group_bb) if _group.profile.location
        with(:group_id, _group.id)
      end
      any_of do
        with(:privacy, MessageThread::PUBLIC)
        if current_user
          all_of do
            with(:group_id, current_user.groups.try(:ids))
            with(:privacy, MessageThread::GROUP)
          end
          all_of do
            with(:group_id, current_user.in_group_committee.map(&:id))
            with(:privacy, MessageThread::COMMITTEE)
          end
        end
      end
      adjust_solr_params do |sunspot_params|
        sunspot_params[:boost] = "recip(ms(NOW,latest_activity_at_dts),3.16e-11,1,1)"
      end
      paginate page: helpers.safe_search_page(params[:thread_page]), per_page: 40
    end
    @unviewed_thread_ids = MessageThread.where(id: threads.results.map(&:id)).unviewed_for(current_user).ids.uniq
    @threads = ThreadListDecorator.decorate_collection threads.results

    # Issues
    issues = Issue.search(include: %i[created_by tags]) do
      fulltext params[:query] do
        boost_fields title: 2.0
        boost_fields tags_string: 1.0
      end
      with(:location).in_bounding_box(*group_bb) if _group.profile.location
      adjust_solr_params do |sunspot_params|
        sunspot_params[:boost] = "recip(ms(NOW,latest_activity_at_dts),3.16e-11,1,1)"
      end
      paginate page: helpers.safe_search_page(params[:issue_page]), per_page: 40
    end
    @issues = IssueDecorator.decorate_collection issues.results

    # Library Items
    library_items = Library::Item.search do
      fulltext params[:query]
      paginate page: helpers.safe_search_page(params[:library_page]), per_page: 40
    end
    @library_items = Library::ItemDecorator.decorate_collection library_items.results

    planning_applications = PlanningApplication
                            .search(params[:query])
                            .intersects(group.profile.location)
                            .includes(:users, :issue)
                            .page params[:planning_page]
    @planning_applications = PlanningApplicationDecorator.decorate_collection planning_applications

    @hashtags = group.hashtags.search(params[:query])
  end

  private

  def group
    @group ||= if params[:id]
                 Group.find(params[:id])
               elsif current_group
                 current_group
               end
  end

  def index_start_location
    return current_user.start_location if current_user && current_user.start_location != SiteConfig.first.nowhere_location
    return current_group.start_location if current_group&.start_location

    SiteConfig.first.nowhere_location
  end

  def group_feature(group, bbox = nil)
    geom = bbox.to_geometry if bbox

    group.loc_feature(title: group.name,
                      size_ratio: group.profile.size_ratio(geom),
                      url: root_url(subdomain: SubdomainConstraint.subdomain(group.short_name)),
                      description: view_context.auto_link(group.trunctated_description))
  end

  def group_bb
    @group_bb ||= begin
                    bb = RGeo::Cartesian::BoundingBox.create_from_geometry group.profile.location
                    [[bb.min_y, bb.min_x], [bb.max_y, bb.max_x]]
                  end
  end
end
