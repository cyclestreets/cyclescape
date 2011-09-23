class IssuesController < ApplicationController

  before_filter :authenticate_user!, only: [:new, :create]
  
  def index
    @issues = Issue.all
  end

  def show
    @issue = Issue.find(params[:id])

    @map = MapLayers::Map.new("map", displayProjection:  OpenLayers::Projection.new("EPSG:4326")) do |map, page|
      page << map.add_layer(MapLayers::OSM_MAPNIK)
      page << map.setCenter(OpenLayers::LonLat.new(@issue.location.x,@issue.location.y).transform(OpenLayers::Projection.new("EPSG:4326"), map.getProjectionObject()),15);
    end
  end

  def new
    @issue = Issue.new
  end

  def create
    @issue = current_user.issues.new(params[:issue])

    # Fake some coordinates around cambridge
    lat = 52.19 + (0.03 * rand)
    lon = 0.09 + (0.08 * rand)

    @issue.location = "POINT(#{lon} #{lat})"

    if @issue.save
      redirect_to action: :index
    else
      render :new
    end
  end

end
