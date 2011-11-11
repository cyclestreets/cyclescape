class Admin::UsersController < ApplicationController
  def index
    @users = User.order("created_at DESC")
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user])
      set_flash_message(:success)
      redirect_to action: :index
    else
      render :edit
    end
  end
end
