class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_auth_user
  filter_access_to :all

  protected

  def set_auth_user
    Authorization.current_user = current_user
    Authorization.ignore_access_control(current_user.root?) if current_user
  end
end
