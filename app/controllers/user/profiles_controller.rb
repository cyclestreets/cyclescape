class User::ProfilesController < ApplicationController
  before_filter :load_user, :load_profile

  def show
  end

  def edit
  end

  def create
    update
  end

  def update
    if @profile.update_attributes(params[:user_profile])
      flash.notice = t(".user.profiles.update.profile_updated")
      redirect_to action: :show
    else
      render :edit
    end
  end

  protected

  def load_user
    @user = User.find(params[:user_id])
  end

  def load_profile
    @profile = @user.profile
  end
end
