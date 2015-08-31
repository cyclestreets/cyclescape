class Api::V1::IssuesController < ApplicationController
  respond_to :json

  def index
    scope = Issue.all
    scope.intersects_not_covered(bbox_from_string(params[:bbox], Issue.rgeo_factory).to_geometry) if params[:bbox].present?
    scope.where_tag_names_in(params[:tags]) if params[:tags]
    scope = scope.before_date(params[:end_date]) if params[:end_date]
    scope = scope.after_date(params[:start_date]) if params[:start_date]
    per_page = [params[:per_page] || 200, 500].min
    issues = scope.paginate(page: params[:page], per_page: per_page)
    issues = issues.map { | issue | issue_feature(issue) }
    collection = RGeo::GeoJSON::EntityFactory.new.feature_collection(issues)
    render json: RGeo::GeoJSON.encode(collection)
  end


  private

  def issue_feature(issue)
    creator_name = if permitted_to? :view_profile, issue.created_by
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
                      cyclescape_url: polymorphic_url(issue, only_path: false)
                     )
  end
end
