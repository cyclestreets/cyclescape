require 'grape-swagger-rails'

module IssueApi
  class API < Grape::API
    include Grape::Kaminari

    version 'v1', using: :accept_version_header
    default_format :json
    prefix :api

    helpers do
      def issue_feature(issue)
        creator_name = if issue.created_by.profile.visibility == 'public'
                         issue.created_by.name
                       else
                         issue.created_by.display_name_or_anon
                       end

        issue = IssueDecorator.decorate issue
        RGeo::GeoJSON::Feature.new(issue.location, nil, id: issue.id,
                                   created_at: issue.created_at.to_i,
                                   created_by: creator_name,
                                   vote_count: issue.vote_count,
                                   thumbnail: issue.medium_icon_path,
                                   photo_thumb_url: issue.photo_medium.try(:url),
                                   title: issue.title,
                                   description: issue.description,
                                   deadline: issue.deadline.to_i,
                                   external_url: issue.external_url,
                                   tags: issue.tags.pluck(:name),
                                   cyclescape_url: "#{request.base_url}/issues/#{issue.to_param}",
                                   latest_activity_at: issue.latest_activity_at.to_i,
                                   closed: issue.closed?)
      end

      def group_feature(group, bbox = nil)
        geom = bbox.to_geometry if bbox

        group.loc_feature(title: group.name,
                          size_ratio: group.profile.size_ratio(geom),
                          url: ["#{request.scheme}://", "#{group.short_name}.", request.host_with_port.sub(/.*?\./, "")].join(""),
                          website: group.website,
                          email: group.email,
                          description: group.trunctated_description)
      end

      def bbox_from_string(string, factory)
        return unless string
        minlon, minlat, maxlon, maxlat = string.split(',').collect(&:to_f)
        bbox = RGeo::Cartesian::BoundingBox.new(factory)
        bbox.add(factory.point(minlon, minlat)).add(factory.point(maxlon, maxlat))
      end
    end

    paginate per_page: 200, max_per_page: 500, offset: false

    resource :tags do
      desc 'Returns tags used on issues, library items and threads'

      get '/' do
        Tag.top_tags(params[:per_page]).offset(params[:per_page].to_i * params[:page].to_i)
      end
    end

    resource :groups do
      desc 'Returns groups as a GeoJSON collection'
      params do
        optional :bbox, type: String, desc: 'Four comma-separated coordinates making up the boundary of interest, e.g. "0.11905,52.20791,0.11907,52.20793"'
        optional :national, type: Integer, desc: 'When set to 1 groups of small and large size are returned, when set to 0 only groups of a small size are returned. Default 0', default: 0
      end

      get '/' do
        scope = GroupProfile.enabled.with_location.ordered_by_size.includes(:group)
        bbox = nil
        if params[:bbox].present?
          bbox = bbox_from_string(params[:bbox], GroupProfile.rgeo_factory)
          scope = scope.intersects(bbox.to_geometry)
        end
        scope = scope.local unless params[:national].to_i == 1
        groups = scope.map { |group_profile| group_feature(GroupDecorator.decorate(group_profile.group), bbox) }
        collection = RGeo::GeoJSON::EntityFactory.new.feature_collection(groups)
        RGeo::GeoJSON.encode(collection)
      end
    end

    resource :issues do
      desc 'Returns issues as a GeoJSON collection'
      params do
        optional :bbox, type: String, desc: 'Four comma-separated coordinates making up the boundary of interest, e.g. "0.11905,52.20791,0.11907,52.20793"'
        optional :tags, type: Array[String], desc: 'An array of tags all the issues must have, e.g. ["taga","tagb"]', coerce_with: JSON, documentation: { is_array: true }
        optional :excluding_tags, type: Array[String], desc: 'An array of tags that the issues must not have, e.g. ["taga","tagb"]', coerce_with: JSON, documentation: { is_array: true }
        optional :group, type: String, desc: 'Return only issues from area of group given by its short name, e.g. "london"'
        optional :order, type: String, desc: 'Order of returned issues. Current working parameters are: "vote_count", "created_at", "start_at", "size"'
        optional :end_date, type: Date, desc: 'No issues after the end date are returned'
        optional :start_date, type: Date, desc: 'No issues before the start date are returned'
      end

      get '/' do
        scope = Issue.all.includes(:created_by, :tags)
        if params[:group]
          group = Group.find_by(short_name: params[:group])
          error! 'Given group not found', 404 unless group
          scope = scope.intersects(group.profile.location)
        end
        case params[:order]
        when 'vote_count'
          scope = scope.plusminus_tally
        when 'created_at', 'start_at'
          scope = scope.order(params[:order] => :desc)
        when 'size'
          scope = scope.order_by_size
        end
        scope = scope.intersects_not_covered(bbox_from_string(params[:bbox], Issue.rgeo_factory).to_geometry) if params[:bbox].present?
        scope = scope.where_tag_names_in(params[:tags]) if params[:tags]
        scope = scope.where_tag_names_not_in(params[:excluding_tags]) if params[:excluding_tags]
        scope = scope.before_date(params[:end_date]) if params[:end_date]
        scope = scope.after_date(params[:start_date]) if params[:start_date]
        scope = paginate scope
        issues = scope.map { |issue| issue_feature(issue) }
        collection = RGeo::GeoJSON::EntityFactory.new.feature_collection(issues)
        RGeo::GeoJSON.encode(collection)
      end
    end

    add_swagger_documentation
  end
end
