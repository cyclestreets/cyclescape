json.array! @issues do |issue|
  json.(issue, :id, :created_at, :description)
  json.tags issue.tags.pluck(:name)
  creator_name = if permitted_to? :view_profile, issue.created_by
                   issue.created_by.name
                 else
                   issue.created_by.display_name_or_anon
                 end
  json.created_by creator_name
  json.location RGeo::GeoJSON.encode(issue.location)
  json.cyclescape_url      polymorphic_url(issue, only_path: false)
end
