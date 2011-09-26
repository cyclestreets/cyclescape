class IssuesController < ApplicationController

  require 'rgeo/geo_json'

  before_filter :authenticate_user!, only: [:new, :create]
  
  def index
    @issues = Issue.all
  end

  def show
    @issue = Issue.find(params[:id])
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

  def location
    @issue = Issue.find(params[:id])
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(@issue.location) }
    end
  end
end
