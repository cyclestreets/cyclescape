class Api::V1::IssuesController < ApplicationController
  respond_to :json

  def index
    @issues = Issue.
      intersects_not_covered(bbox_from_string(params[:bbox], Issue.rgeo_factory).to_geometry).
      where_tag_names_in(params[:tags])
    respond_with @issues
  end
end
