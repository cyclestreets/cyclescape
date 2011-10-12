class User::ProfilesController < ApplicationController
  before_filter :load_profile

  def show
  end

  def edit
  end

  def create
    update
  end

  def update
    if @profile.update_attributes(params[:user_profile])
      redirect_to action: :show
    else
      render :edit
    end
  end

  protected

  def load_profile
    @profile = User.find(params[:user_id]).profile
  end
end
