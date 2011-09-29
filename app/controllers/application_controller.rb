class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_auth_user
  filter_access_to :all

  protected

  def set_auth_user
    Authorization.current_user = current_user
    Authorization.ignore_access_control(current_user && current_user.root?)
  end

  def permission_denied
    if Rails.env.test?
      raise "permission denied"
    else
      redirect_to new_user_session_path
    end
  end
end
