# frozen_string_literal: true

class User::LocationsController < ApplicationController
  def index
    authorize User, :logged_in?
  end

  def create
    # skipping as all current_user's can build locations
    # other auths are skipped as they all go through current_user
    authorize User, :logged_in?
    @location = current_user.location || current_user.build_location

    if @location.update permitted_params
      set_flash_message :success
      redirect_to action: :index
    else
      @full_page = true
      @start_location = SiteConfig.first.nowhere_location
      render :new
    end
  end

  def new
    authorize User, :logged_in?
    # Get the start location before creating a new blank one
    @full_page = true
    @start_location = current_user.start_location
    @location = current_user.location || current_user.build_location
  end

  def update
    authorize User, :logged_in?
    @location = current_user.location

    if @location.update permitted_params
      set_flash_message :success
      redirect_to action: :index
    else
      render :edit
    end
  end

  def geometry
    authorize User, :logged_in?
    @location = current_user.location
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(@location.loc_feature(thumbnail: view_context.image_path("map-icons/m-misc.png"))) }
    end
  end

  def combined_geometry
    authorize User, :logged_in?
    multi = current_user.buffered_location
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(multi) }
    end
  end

  protected

  def permitted_params
    params.require(:user_location).permit :category_id, :loc_json
  end
end
