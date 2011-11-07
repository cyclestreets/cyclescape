class Admin::GroupsController < ApplicationController
  def index
    @groups = Group.all
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(params[:group])

    if @group.save
      set_flash_message(:success)
      redirect_to action: :index
    else
      render :new
    end
  end

  def edit
    @group = Group.find(params[:id])
  end

  def update
    @group = Group.find(params[:id])

    if @group.update_attributes(params[:group])
      set_flash_message(:success)
      redirect_to action: :index
    else
      render :edit
    end
  end
end
