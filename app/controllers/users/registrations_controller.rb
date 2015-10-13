class Users::RegistrationsController < Devise::RegistrationsController

  def create
    if params[:bicycle_wheels].strip == '12' && params[:real_name].blank?
      super
    else
      build_resource(sign_up_params)
      clean_up_passwords(resource)
      flash[:alert] = I18n.t(:failure, scope: "devise.registrations.new")
      render :new
    end
  end

  protected

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
