class Admin::UsersController < ApplicationController
  def index
    @users = User.order('created_at DESC')
  end

  def edit
    @user = User.find params[:id]
  end

  def update
    @user = User.find params[:id]

    if @user.update permitted_params
      set_flash_message :success
      redirect_to action: :index
    else
      render :edit
    end
  end

  def permitted_params
    params.require(:user).permit :email, :full_name, :display_name, :role, :disabled,
      profile_attributes: [:picture, :retained_picture, :website, :about]
  end
end
