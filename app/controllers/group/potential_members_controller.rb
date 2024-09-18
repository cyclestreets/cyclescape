# frozen_string_literal: true

class Group::PotentialMembersController < ApplicationController
  before_action :load_group

  def new; end

  def create
    if @group.update_potetial_members(permitted_params[:emails])
      set_flash_message :success
      redirect_to group_members_path
    else
      render :new
    end
  end

  protected

  def load_group
    @group = Group.find params[:group_id]
    authorize @group, :in_group_committee?
  end

  def permitted_params
    params.require(:potential_members).permit :emails
  end
end
