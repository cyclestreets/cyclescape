# frozen_string_literal: true

module Route
  class GroupApi < Base
    desc 'Returns groups as a GeoJSON collection', security: [{}]
    paginate paginate_settings

    params do
      optional(:bbox, type: RGeo::Cartesian::BoundingBox, coerce_with: BboxCoerce,
                      desc: 'Four comma-separated coordinates making up the boundary of interest, e.g. "0.11905,52.20791,0.11907,52.20793"')
      optional :national, type: Integer, desc: 'When set to 1 groups of small and large size are returned, when set to 0 only groups of a small size are returned. Default 0', default: 0
    end

    helpers do
      def group_feature(group, bbox = nil)
        geom = bbox.to_geometry if bbox

        group.loc_feature(title: group.name,
                          size_ratio: group.profile.size_ratio(geom),
                          url: ["#{request.scheme}://", "#{group.short_name}.", request.host_with_port.sub(/.*?\./, "")].join(""),
                          website: group.website,
                          email: group.email,
                          description: group.trunctated_description)
      end
    end

    get :groups do
      scope = GroupProfile.enabled.with_location.ordered_by_size.includes(:group)
      scope = scope.intersects(params[:bbox].to_geometry) if params[:bbox].present?
      scope = scope.local unless params[:national].to_i == 1
      scope = paginate scope
      groups = scope.map { |group_profile| group_feature(GroupDecorator.decorate(group_profile.group), params[:bbox]) }
      collection = RGeo::GeoJSON::EntityFactory.new.feature_collection(groups)
      RGeo::GeoJSON.encode(collection)
    end
  end
end
