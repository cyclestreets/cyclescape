class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:account_update).push(:full_name, :display_name)
    devise_parameter_sanitizer.for(:sign_up).push(:full_name, :display_name)
  end

  def after_inactive_sign_up_path_for(resource)
    root_url
  end

  def after_sign_up_path_for(resource)
    root_url
  end

  def after_update_path_for(resource)
    edit_user_registration_url
  end
end
