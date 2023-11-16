# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def twitter
    skip_authorization

    @user = User.from_omniauth(request.env["omniauth.auth"])
    store_location_for(@user, current_user_profile_path) if @user.new_record?
    if @user.persisted? || @user.save
      sign_in_and_redirect @user, event: :authentication # this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: "Twitter") if is_navigational_format?
    else
      session["devise.omniauth_data_info"] = request.env["omniauth.auth"].info
      flash[:alert] = t("devise.omniauth.failure", application_name: @site_config.application_name, provider: "Twitter")
      redirect_to new_user_session_path
    end
  end

  def facebook
    skip_authorization

    @user = User.from_omniauth(request.env["omniauth.auth"])
    store_location_for(@user, current_user_profile_path) if @user.new_record?
    if @user.persisted? || @user.save
      sign_in_and_redirect @user, event: :authentication # this will throw if @user is not activated
      set_flash_message(:notice, :success, kind: "Facebook") if is_navigational_format?
    else
      session["devise.omniauth_data_info"] = request.env["omniauth.auth"].info
      flash[:alert] = t("devise.omniauth.failure", application_name: @site_config.application_name, provider: "Facebook")
      redirect_to new_user_session_path
    end
  end

  def failure
    skip_authorization

    redirect_to root_path
  end
end
