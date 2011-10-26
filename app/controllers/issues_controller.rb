class IssuesController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create]
  
  def index
    @issues = Issue.order("created_at DESC").limit(10)

    # This needs more thought!
    @start_location = RGeo::Geos::Factory.create({has_z_coordinate: true}).point(0.1477639423685, 52.27332049515, 14)
  end

  def show
    @issue = Issue.find(params[:id])
  end

  def new
    @issue = Issue.new
    @start_location = RGeo::Geos::Factory.create({has_z_coordinate: true}).point(0.1477639423685, 52.27332049515, 14)
  end

  def create
    @issue = current_user.issues.new(params[:issue])

    if @issue.save
      redirect_to @issue
    else
      @start_location = RGeo::Geos::Factory.create({has_z_coordinate: true}).point(0.1477639423685, 52.27332049515, 14)
      render :new
    end
  end

  def geometry
    @issue = Issue.find(params[:id])
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(@issue.location) }
    end
  end

  def all_geometries
    if params[:bbox]
      bbox = bbox_from_string(params[:bbox], Issue.rgeo_factory)
      issues = Issue.intersects(bbox.to_geometry).order("created_at DESC").limit(50)
    else
      issues = Issue.order("created_at DESC").limit(50)
    end
    factory = RGeo::Geos::Factory.new
    collection = factory.collection(issues.map { | issue | issue.location})
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(collection)}
    end
  end
end
