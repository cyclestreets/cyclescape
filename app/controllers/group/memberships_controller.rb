# frozen_string_literal: true

class Group::MembershipsController < ApplicationController
  before_action :load_group

  def new
    @membership = @group.memberships.new
    authorize @membership
    @membership.build_user
  end

  def create
    @membership = @group.memberships.new permitted_params
    authorize @membership

    if @membership.save
      Notifications.added_to_group(@membership).deliver_later if @membership.user.accepted_or_not_invited?
      redirect_to group_members_path
    else
      render :new
    end
  end

  def edit
    @membership = @group.memberships.find params[:id]
    authorize @membership
  end

  def update
    @membership = @group.memberships.find params[:id]
    authorize @membership

    if @membership.update permitted_params
      set_flash_message :success
      redirect_to group_members_path
    else
      set_flash_message :failure
      render :edit
    end
  end

  def destroy
    @membership = @group.memberships.find params[:id]
    authorize @membership

    if @membership.destroy
      set_flash_message :success
    else
      set_flash_message :failure
    end

    redirect_to group_members_path
  end

  protected

  def load_group
    @group = Group.find params[:group_id]
  end

  def permitted_params
    params.require(:group_membership).permit :user_id, :role, user_attributes: %i[full_name email]
  end
end
