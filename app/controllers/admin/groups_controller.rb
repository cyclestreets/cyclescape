# frozen_string_literal: true

class Admin::GroupsController < ApplicationController
  def index
    @groups = Group.ordered
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(permitted_params)

    if @group.save
      set_flash_message(:success)
      redirect_to action: :index
    else
      render :new
    end
  end

  def edit
    group
  end

  def update
    if group.update permitted_params
      set_flash_message :success
      redirect_to action: :index
    else
      render :edit
    end
  end

  def disable
    group.disable!
    redirect_to action: :index
  end

  def enable
    group.enable!
    redirect_to action: :index
  end

  protected

  def permitted_params
    params.require(:group).permit :name, :short_name, :website, :email, :default_thread_privacy
  end

  def group
    @group ||= Group.find params[:id]
  end
end
