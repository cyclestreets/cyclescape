require 'grape-swagger'

module IssueApi
  class API < Grape::API
    include Grape::Kaminari

    version 'v1', using: :accept_version_header
    format :json
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
                          photo_thumb_url: issue.standard_photo_url,
                          title: issue.title,
                          description: issue.description,
                          deadline: issue.deadline.to_i,
                          external_url: issue.external_url,
                          tags: issue.tags.pluck(:name),
                          cyclescape_url: "#{request.base_url}/issues/#{issue.to_param}"
                         )
      end

      def bbox_from_string(string, factory)
        return unless string
        minlon, minlat, maxlon, maxlat = string.split(',').collect { |i| i.to_f }
        bbox = RGeo::Cartesian::BoundingBox.new(factory)
        bbox.add(factory.point(minlon, minlat)).add(factory.point(maxlon, maxlat))
      end
    end

    paginate per_page: 200, max_per_page: 500, offset: false

    desc 'Returns issues as a GeoJSON collection'
    params do
      optional :bbox, type: String, desc: 'Four comma-separated coordinates making up the boundary of interest, e.g. "0.11905,52.20791,0.11907,52.20793"'
      optional :tags, type: Array, desc: 'An array of tags all the issues must have, e.g. ["taga","tagb"]', coerce_with: JSON
      optional :group, type: String, desc: 'Return only issues from area of group given by its short name, e.g. "london"'
      optional :order, type: String, desc: 'Order of returned issues. Current working parameters are: "vote_count", "created_at", "start_at", "size"'
      optional :end_date, type: Date, desc: 'No issues after the end date are returned'
      optional :start_date, type: Date, desc: 'No issues before the start date are returned'
    end

    get '/issues' do
      scope = Issue.all.includes(:created_by, :tags)
      if params[:group]
        group = Group.find_by(short_name: params[:group])
        error! 'Given group not found', 404 if !group
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
      scope = scope.before_date(params[:end_date]) if params[:end_date]
      scope = scope.after_date(params[:start_date]) if params[:start_date]
      scope = paginate scope
      issues = scope.map { | issue | issue_feature(issue) }
      collection = RGeo::GeoJSON::EntityFactory.new.feature_collection(issues)
      RGeo::GeoJSON.encode(collection)
    end

    add_swagger_documentation
  end
end
