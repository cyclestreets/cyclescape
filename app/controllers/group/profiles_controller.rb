class Group::ProfilesController < ApplicationController
  before_filter :load_group
  filter_access_to :edit, :update, attribute_check: true, model: Group
  filter_access_to :all

  def show
    @profile = @group.profile
  end

  def edit
    @profile = @group.profile
    # This needs more thought!
    @start_location = RGeo::Geos::Factory.create({has_z_coordinate: true}).point(0.1477639423685, 52.27332049515, 10)
  end

  def update
    if @group.profile.update_attributes(params[:group_profile])
      flash.notice = t("group.profiles.update.profile_updated")
      redirect_to action: :show
    else
      render :edit
    end
  end

  def geometry
    @profile = @group.profile
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(@profile.location) }
    end
  end

  protected

  def load_group
    @group = Group.find(params[:group_id])
  end
end
