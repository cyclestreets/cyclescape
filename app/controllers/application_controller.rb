class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_auth_user
  filter_access_to :all

  protected

  def set_auth_user
    Authorization.current_user = current_user
  end

  def permission_denied
    if current_user.nil?
      flash.alert = t("permission_denied_sign_in")
      redirect_to new_user_session_path
    else
      flash.alert = t("permission_denied")
      render status: :unauthorized, text: "You are not authorised to access that page."
    end
  end
end
