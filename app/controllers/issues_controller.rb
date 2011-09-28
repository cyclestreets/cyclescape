class IssuesController < ApplicationController

  require 'rgeo/geo_json'

  before_filter :authenticate_user!, only: [:new, :create]
  
  def index
    @issues = Issue.order("created_at DESC").limit(10)

    # This needs more thought!
    @start_location = RGeo::Geos::Factory.create.point(0.1477639423685, 52.27332049515)
  end

  def show
    @issue = Issue.find(params[:id])
  end

  def new
    @issue = Issue.new
  end

  def create
    @issue = current_user.issues.new(params[:issue])

    if @issue.save
      redirect_to @issue
    else
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
      minlon, minlat, maxlon, maxlat = params[:bbox].split(",").collect{|i| i.to_f}
      issues = Issue.where("st_intersects(location, setsrid('BOX3D(? ?, ? ?)'::box3d, 4326))", minlon, minlat, maxlon, maxlat).order("created_at DESC").limit(50)
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
