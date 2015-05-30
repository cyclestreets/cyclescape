class Admin::GroupsController < ApplicationController
  before_filter :load_group, only: [:edit, :update]

  def index
    @groups = Group.all
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
  end

  def update
    if @group.update_attributes permitted_params
      set_flash_message :success
      redirect_to action: :index
    else
      render :edit
    end
  end

  protected

  def permitted_params
    params.require(:group).permit :name, :short_name, :website, :email, :default_thread_privacy
  end

  def load_group
    @group ||= Group.find params[:id]
  end

end
