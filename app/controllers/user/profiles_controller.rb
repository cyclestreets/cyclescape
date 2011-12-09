class User::ProfilesController < ApplicationController
  before_filter :load_user, :load_profile
  filter_access_to :edit, :create, :update, attribute_check: true, model: User
  filter_access_to :all

  def show
    # Groups that the current user could invite this particular user to
    @add_to_groups = (current_user.memberships.committee.collect{ |m| m.group } - @user.groups)
  end

  def edit
  end

  def create
    update
  end

  def update
    if @profile.update_attributes(params[:user_profile])
      set_flash_message(:success)
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
