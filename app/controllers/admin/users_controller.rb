class Admin::UsersController < ApplicationController
  def index
    @full_page = true
    @users = User.order('created_at DESC').page(params[:page]).includes(:profile)
  end

  def edit
    user
  end

  def approve
    user.approve!
  end

  def update
    if user.update permitted_params
      set_flash_message :success
      redirect_to action: :index
    else
      render :edit
    end
  end

  protected

  def user
    @user ||= User.find(params[:id])
  end

  def permitted_params
    params.require(:user).permit :email, :full_name, :display_name, :role, :disabled,
      profile_attributes: [:picture, :retained_picture, :website, :about]
  end

end
