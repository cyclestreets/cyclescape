# frozen_string_literal: true

class Admin::UsersController < ApplicationController
  def index
    @full_page = true
    @users = User.order('created_at DESC').page(params[:page]).includes(:profile)
    @users = @users.search_by_full_name(params[:full_name]) if params[:full_name]
    @users = @users.search_by_display_name(params[:display_name]) if params[:display_name]
    @users = @users.search_by_email(params[:email]) if params[:email]
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

  def destroy
    if user.destroy
      set_flash_message :success
    else
      set_flash_message :failure
    end
    redirect_to action: :index
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
