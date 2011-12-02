class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :no_disabled_users
  before_filter :set_auth_user
  before_filter :set_default_mailer_options
  layout :set_xhr_layout
  filter_access_to :all

  protected

  def no_disabled_users
    if current_user.present? && current_user.disabled_at?
      sign_out current_user
      redirect_to root_path, :alert => t("application.account_disabled")
    end
  end

  def set_auth_user
    Authorization.current_user = current_user
  end

  def set_default_mailer_options
    ActionMailer::Base.default_url_options[:host] = request.host
    ActionMailer::Base.default_url_options[:port] = (request.port == 80) ? nil : request.port
  end

  def set_xhr_layout
    if request.xhr? then nil else "application" end
  end

  def permission_denied
    if current_user.nil?
      authenticate_user!
    else
      render status: :unauthorized, text: t(".application.permission_denied")
    end
  end

  def after_sign_in_path_for(resource)
    dashboard_path
  end

  def set_flash_message(type, options = {})
    flash_key = if type == :success then :notice else :alert end
    options.reverse_merge!(scope: "#{controller_path.gsub('/', '.')}.#{action_name}")
    flash[flash_key] = I18n.t(type, options)
  end

  # A method to convert an openlayers-format bbox string into an rgeo bbox object
  def bbox_from_string(string, factory)
    minlon, minlat, maxlon, maxlat = string.split(",").collect{|i| i.to_f}
    bbox = RGeo::Cartesian::BoundingBox.new(factory)
    bbox.add(factory.point(minlon, minlat)).add(factory.point(maxlon, maxlat))
  end
end
