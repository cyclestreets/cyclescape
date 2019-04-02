# frozen_string_literal: true

class Group::ProfilesController < ApplicationController
  before_action :load_group_profile
  filter_access_to :edit, :update, attribute_check: true, model: Group
  filter_access_to :all

  def show
  end

  def edit
    # This needs more thought!
    @start_location = SiteConfig.first.nowhere_location
  end

  def update
    if @profile.update permitted_params
      set_flash_message :success
      redirect_to action: :show
    else
      @start_location = @profile.location || SiteConfig.first.nowhere_location
      render :edit
    end
  end

  def geometry
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(@profile.loc_feature(thumbnail: view_context.image_path('map-icons/m-misc.png'))) }
    end
  end

  protected

  def load_group_profile
    @group = Group.includes(:profile).find params[:group_id]
    @profile = @group.profile
  end

  def permitted_params
    params.require(:group_profile).permit(
      :description, :joining_instructions, :loc_json, :retained_picture, :new_user_email,
      :retained_logo, :base64_picture, :base64_logo
    )
  end
end
