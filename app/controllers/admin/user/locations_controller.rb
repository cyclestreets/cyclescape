class Admin::User::LocationsController < ApplicationController
  before_filter :load_user

  def index
    set_page_title t("admin.user.locations.index.title", user_name: @user.name)
  end

  def new
    set_page_title t("admin.user.locations.new.title", user_name: @user.name)

    # Get the start location before creating a new blank one
    @start_location = @user.start_location
    @location = @user.locations.new
  end

  def create
    @location = @user.locations.new(params[:user_location])

    if @location.save
      set_flash_message(:success)
      redirect_to action: :index
    else
      @start_location = Geo::NOWHERE_IN_PARTICULAR
      render :new
    end
  end

  def edit
    set_page_title t("admin.user.locations.edit.title", user_name: @user.name)

    @location = @user.locations.find(params[:id])
    @start_location = @location.location
  end

  def update
    @location = @user.locations.find(params[:id])

    if @location.update_attributes(params[:user_location])
      set_flash_message(:success)
      redirect_to action: :index
    else
      render :edit
    end
  end

  def geometry
    @location = @user.locations.find(params[:id])
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(@location.loc_feature(thumbnail: view_context.image_path("map-icons/m-misc.png"))) }
    end
  end

  def combined_geometry
    multi = @user.buffered_locations
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(multi) }
    end
  end

  private

  def load_user
    @user = User.find(params[:user_id])
  end
end
