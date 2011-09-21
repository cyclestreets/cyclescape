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
      flash.notice = t(".group_updated")
      redirect_to action: :index
    else
      render :edit
    end
  end
end
