# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  def create
    skip_authorization

    if params[:bicycle_wheels].try(:strip) == "12" && params[:real_name].blank?
      super
    else
      build_resource(sign_up_params)
      clean_up_passwords(resource)
      flash[:alert] = I18n.t(:failure, scope: "devise.registrations.new")
      render :new
    end
  end

  protected

  def after_inactive_sign_up_path_for(_resource)
    root_url
  end

  def after_sign_up_path_for(_resource)
    root_url
  end

  def after_update_path_for(_resource)
    edit_user_registration_url
  end
end
