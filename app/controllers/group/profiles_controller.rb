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
    @start_location = Geo::NOWHERE_IN_PARTICULAR
  end

  def update
    if @group.profile.update permitted_params
      set_flash_message :success
      redirect_to action: :show
    else
      render :edit
    end
  end

  def geometry
    @profile = @group.profile
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(@profile.loc_feature(thumbnail: view_context.image_path('map-icons/m-misc.png'))) }
    end
  end

  protected

  def load_group
    @group = Group.find params[:group_id]
  end

  def permitted_params
    params.require(:group_profile).permit :description, :joining_instructions, :loc_json
  end
end
