# frozen_string_literal: true

class Admin::User::LocationsController < ApplicationController
  before_action :load_user

  def index
    set_page_title t('admin.user.locations.index.title', user_name: @user.name)
  end

  def new
    set_page_title t('admin.user.locations.new.title', user_name: @user.name)

    # Get the start location before creating a new blank one
    @start_location = @user.start_location
    @location = @user.build_location
  end

  def create
    @location = @user.build_location permitted_params

    if @location.save
      set_flash_message(:success)
      redirect_to action: :index
    else
      @start_location = SiteConfig.first.nowhere_location
      render :new
    end
  end

  def edit
    set_page_title t('admin.user.locations.edit.title', user_name: @user.name)

    @location = @user.location
    @start_location = @location.location
  end

  def update
    @location = @user.location

    if @location.update permitted_params
      set_flash_message(:success)
      redirect_to action: :index
    else
      render :edit
    end
  end

  def geometry
    @location = @user.location
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(@location.loc_feature(thumbnail: view_context.image_path('map-icons/m-misc.png'))) }
    end
  end

  def combined_geometry
    multi = @user.buffered_location
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(multi) }
    end
  end

  private

  def load_user
    @user = User.find(params[:user_id])
  end

  def permitted_params
    params.require(:user_location).permit :category_id, :loc_json
  end
end
