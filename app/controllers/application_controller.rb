class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :ensure_proper_protocol
  before_filter :no_disabled_users
  before_filter :set_auth_user
  before_filter :load_group_from_subdomain
  before_filter :set_page_title
  layout :set_xhr_layout
  filter_access_to :all

  protected

  def ssl_allowed_action?
    (params[:controller] == 'devise/sessions' && ['new', 'create'].include?(params[:action])) ||
      (params[:controller] == 'devise/registrations' && ['new', 'create', 'edit', 'update'].include?(params[:action])) ||
      (params[:controller] == 'devise/omniauth_callbacks')
  end

  def ensure_proper_protocol
    if request.ssl? && !ssl_allowed_action?
      flash.keep
      redirect_to "http://" + request.host + request.fullpath
    end
  end

  def after_sign_in_path_for(resource_or_scope)
    dashboard_path(:protocol => 'http')
  end

  def after_sign_out_path_for(resource_or_scope)
    root_url(:protocol => 'http')
  end

  def no_disabled_users
    if current_user.present? && current_user.disabled_at?
      sign_out current_user
      redirect_to root_path, :alert => t("application.account_disabled")
    end
  end

  def set_auth_user
    Authorization.current_user = current_user
  end

  def set_xhr_layout
    if request.xhr? then nil else "application" end
  end

  def load_group_from_subdomain
    if is_group_subdomain?
      @current_group = Group.find_by_short_name(request.subdomain)
    end
  end

  def set_page_title(title = nil)
    if title
      page_title = title
    else
      key = "#{controller_path.tr("/", ".")}.#{params[:action]}.title"
      page_title = I18n.translate(key, default: "")
    end
    app_title = I18n.translate("application_name")
    @page_title = if page_title == "" then app_title else "#{page_title} - #{app_title}" end
  end

  def page_title
    @page_title
  end
  helper_method :page_title

  def is_group_subdomain?
    request.subdomain != "www"
  end

  def current_group
    @current_group
  end
  helper_method :current_group

  def permission_denied
    if current_user.nil?
      authenticate_user!
    else
      render status: :unauthorized, text: t(".application.permission_denied")
    end
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
