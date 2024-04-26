# frozen_string_literal: true

class Group::ProfilesController < ApplicationController
  before_action :load_group_profile

  def show
    skip_authorization
  end

  def edit
    authorize @profile
    # This needs more thought!
    @start_location = SiteConfig.first.nowhere_location
  end

  def update
    authorize @profile
    if @profile.update permitted_params
      set_flash_message :success
      redirect_to action: :show
    else
      @start_location = @profile.location || SiteConfig.first.nowhere_location
      render :edit
    end
  end

  def geometry
    skip_authorization
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(@profile.loc_feature(thumbnail: view_context.image_path("map-icons/m-misc.png"))) }
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
