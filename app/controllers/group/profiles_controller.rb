class Group::ProfilesController < ApplicationController

  require 'rgeo/geo_json'

  def show
    @profile = Group.find(params[:group_id]).profile
  end

  def edit
    @profile = Group.find(params[:group_id]).profile
  end

  def update
    @group = Group.find(params[:group_id])

    if @group.profile.update_attributes(params[:profile])
      flash.notice = t(".profile_updated")
      redirect_to action: :index
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
