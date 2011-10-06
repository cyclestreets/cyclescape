class Group::ProfilesController < ApplicationController

  require 'rgeo/geo_json'

  def show
    @profile = Group.find(params[:group_id]).profile
  end

  def edit
    @profile = Group.find(params[:group_id]).profile
    # This needs more thought!
    @start_location = RGeo::Geos::Factory.create({has_z_coordinate: true}).point(0.1477639423685, 52.27332049515, 10)
  end

  def update
    @group = Group.find(params[:group_id])

    if @group.profile.update_attributes(params[:group_profile])
      flash.notice = t(".profile_updated")
      redirect_to action: :show
    else
      render :edit
    end
  end

  def geometry
    @profile = Group.find(params[:group_id]).profile
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(@profile.location) }
    end
  end
end
