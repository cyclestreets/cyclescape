# frozen_string_literal: true

class Group::PotentialMembersController < ApplicationController
  before_action :load_group
  filter_access_to :all, attribute_check: true, model: Group

  def new
  end

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
  end

  def permitted_params
    params.require(:potential_members).permit :emails
  end
end
