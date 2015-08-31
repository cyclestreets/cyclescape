module IssueApi
  class API < Grape::API
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

        issue.loc_feature(id: issue.id,
                          created_at: issue.created_at,
                          created_by: creator_name,
                          description: issue.description,
                          deadline: issue.deadline,
                          external_url: issue.external_url,
                          tags: issue.tags.pluck(:name),
                          cyclescape_url: "http://www.cyclescape.org/issues/#{issue.to_param}"
                         )
      end

      def bbox_from_string(string, factory)
        return unless string
        minlon, minlat, maxlon, maxlat = string.split(',').collect { |i| i.to_f }
        bbox = RGeo::Cartesian::BoundingBox.new(factory)
        bbox.add(factory.point(minlon, minlat)).add(factory.point(maxlon, maxlat))
      end
    end

    desc 'Returns issues as a GeoJSON collection'
    params do
      optional :bbox, type: String, desc: 'Four comma-separated coordinates making up the boundary of interest, e.g. "0.11905,52.20791,0.11907,52.20793"'
      optional :tags, type: Array, desc: 'An array of tags all the issues must have, e.g. ["taga","tagb"]'
      optional :end_date, type: Date, desc: 'No issues after the end date are returned'
      optional :start_date, type: Date, desc: 'No issues before the start date are returned'
      optional :per_page, type: Integer, default: 200, desc: 'The number of issues per page, maximum of 500'
      optional :page, type: Integer, desc: 'The page number'
    end
    get '/issues' do
      scope = Issue.all.includes(:created_by, :tags)
      scope.intersects_not_covered(bbox_from_string(params[:bbox], Issue.rgeo_factory).to_geometry) if params[:bbox].present?
      scope.where_tag_names_in(params[:tags]) if params[:tags]
      scope = scope.before_date(params[:end_date]) if params[:end_date]
      scope = scope.after_date(params[:start_date]) if params[:start_date]
      per_page = [params[:per_page], 500].min
      issues = scope.paginate(page: params[:page], per_page: per_page)
      issues = issues.map { | issue | issue_feature(issue) }
      collection = RGeo::GeoJSON::EntityFactory.new.feature_collection(issues)
      RGeo::GeoJSON.encode(collection)
    end

  end
end
