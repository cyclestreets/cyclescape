# frozen_string_literal: true

class User::PrefsController < ApplicationController
  before_filter :load_user
  filter_access_to :edit, :update, attribute_check: true, model: User

  def edit
    @prefs = @user.prefs
  end

  def update
    @prefs = @user.prefs

    if @prefs.update permitted_params
      set_flash_message :success
    else
      set_flash_message :failure
    end
    redirect_to action: 'edit'
  end

  protected

  def load_user
    @user = params[:user_id] ? User.find(params[:user_id]) : current_user
    permission_denied unless @user
  end

  def permitted_params
    params.require(:user_pref).permit :involve_my_locations, :involve_my_groups, :involve_my_groups_admin, :email_status_id
  end
end
