class Api::V1::IssuesController < ApplicationController
  respond_to :json

  def index
    scope = Issue.all
    scope.intersects_not_covered(bbox_from_string(params[:bbox], Issue.rgeo_factory).to_geometry) if params[:bbox].present?
    scope.where_tag_names_in(params[:tags]) if params[:tags]
    scope = scope.before_date(params[:end_date]) if params[:end_date]
    scope = scope.after_date(params[:start_date]) if params[:start_date]
    per_page = [params[:per_page] || 200, 500].min
    @issues = scope.paginate(page: params[:page], per_page: per_page)
    respond_with @issues
  end

end
