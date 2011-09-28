class IssuesController < ApplicationController

  require 'rgeo/geo_json'

  before_filter :authenticate_user!, only: [:new, :create]
  
  def index
    @issues = Issue.order("created_at DESC").limit(10)
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
end
