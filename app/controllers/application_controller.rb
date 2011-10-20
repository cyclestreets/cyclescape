class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_auth_user
  before_filter :set_default_mailer_options
  filter_access_to :all

  protected

  def set_auth_user
    Authorization.current_user = current_user
  end

  def set_default_mailer_options
    ActionMailer::Base.default_url_options[:host] = request.host
    ActionMailer::Base.default_url_options[:port] = (request.port == 80) ? nil : request.port
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

  def set_flash_message(type, options = {})
    flash_key = if type == :success then :notice else :alert end
    options.reverse_merge!(scope: "#{controller_path.gsub('/', '.')}.#{action_name}")
    flash[flash_key] = I18n.t(type, options)
  end
end
