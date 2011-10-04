class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_auth_user
  filter_access_to :all

  protected

  def set_auth_user
    Authorization.current_user = current_user
  end

  def permission_denied
    redirect_to new_user_session_path if current_user.nil?
  end
end
