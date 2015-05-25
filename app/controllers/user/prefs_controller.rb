class User::PrefsController < ApplicationController
  before_filter :load_user
  filter_access_to :edit, :update, attribute_check: true, model: User

  def edit
    @prefs = @user.prefs
  end

  def update
    @prefs = @user.prefs

    if @prefs.update_attributes(params[:user_pref])
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
end
