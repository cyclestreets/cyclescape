class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :ensure_proper_protocol
  before_filter :no_disabled_users
  before_filter :set_auth_user
  before_filter :load_group_from_subdomain
  before_filter :set_page_title
  after_filter :remember_current_group
  after_filter :store_location
  layout :set_xhr_layout
  filter_access_to :all
  helper_method :group_subdomain?
  before_filter :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :full_name
    devise_parameter_sanitizer.for(:accept_invitation).push *[:full_name, :display_name, :email]
  end

  def ssl_allowed_action?
    (params[:controller] == 'devise/sessions' && %w(new create).include?(params[:action])) ||
      (params[:controller] == 'devise/registrations' && %w(new create edit update).include?(params[:action])) ||
      (params[:controller] == 'devise_invitable/registrations' && %w(new create edit update).include?(params[:action])) ||
      (params[:controller] == 'devise/omniauth_callbacks')
  end

  def ensure_proper_protocol
    if request.ssl? && !ssl_allowed_action?
      flash.keep
      redirect_to 'http://' + request.host + request.fullpath # FIXME not safe for domains with ports
    end
  end

  # We want to tightly control where users end up after signing in.
  # If they hit a protected resource, devise has stored the location they were attempting
  # If they volunteer to sign in, we've previously stored the location using after_filters in the devise cookie
  # If they were on the front page, we want to redirect them to the dashboard instead
  # If they have a remembered_group, then we want to inject the subdomain into any of the above
  # We need to do all of that without messing up domains or ports
  # ... and we need to make sure they go back to an http page, so that non-https maps can load.
  def after_sign_in_path_for(resource_or_scope)
    s = stored_location_for(resource_or_scope) # nb returns and deletes
    if s && s[0] == '/' && s != '/'
      s.slice!(0) # remove the leading slash
      if current_user.remembered_group?
        # is there a cleaner way than using root_url?
        root_url(protocol: 'http', subdomain: current_user.remembered_group.short_name) + s
      else
        root_url(protocol: 'http') + s
      end
    else
      if current_user.remembered_group?
        dashboard_url(protocol: 'http', subdomain: current_user.remembered_group.short_name)
      else
        dashboard_url(protocol: 'http')
      end
    end
  end

  # continuously store the location, for redirecting after login
  def store_location
    if request.get? && request.format.html? && !request.xhr? && !devise_controller?
      session[:"user_return_to"] = request.fullpath
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    root_url(protocol: 'http')
  end

  def no_disabled_users
    if current_user.present? && current_user.disabled_at?
      sign_out current_user
      redirect_to root_path, alert: t('application.account_disabled')
    end
  end

  def set_auth_user
    Authorization.current_user = current_user
  end

  def set_xhr_layout
    if request.xhr? then nil else 'application' end
  end

  def load_group_from_subdomain
    if is_group_subdomain?
      @current_group = Group.find_by_short_name(request.subdomain)
      unless @current_group
        redirect_to(subdomain: 'www')
      end
    end
  end

  def set_page_title(title = nil)
    if title
      page_title = title
    else
      key = "#{controller_path.tr("/", ".")}.#{params[:action]}.title"
      page_title = I18n.translate(key, default: '')
    end
    app_title = I18n.translate('application_name')
    @page_title = if page_title == '' then app_title else "#{page_title} - #{app_title}" end
  end

  def page_title
    @page_title
  end
  helper_method :page_title

  def is_group_subdomain?
    !request.subdomain.blank? && request.subdomain != 'www'
  end

  def group_subdomain?(group = nil)
    !request.subdomain.blank? && request.subdomain == group
  end

  def current_group
    @current_group
  end
  helper_method :current_group

  def remember_current_group
    return unless current_user
    # Poor man's skip_filter to avoid a new Devise-inherited controller
    return if params[:controller] == 'devise/sessions'
    current_user.update_remembered_group(current_group)
  end

  def permission_denied
    if current_user.nil?
      authenticate_user!
    else
      render status: :unauthorized, text: t('.application.permission_denied')
    end
  end

  def set_flash_message(type, options = {})
    flash_key = if type == :success then :notice else :alert end
    options.reverse_merge!(scope: "#{controller_path.gsub('/', '.')}.#{action_name}")
    flash[flash_key] = I18n.t(type, options)
  end

  # A method to convert an openlayers-format bbox string into an rgeo bbox object
  def bbox_from_string(string, factory)
    minlon, minlat, maxlon, maxlat = string.split(',').collect { |i| i.to_f }
    bbox = RGeo::Cartesian::BoundingBox.new(factory)
    bbox.add(factory.point(minlon, minlat)).add(factory.point(maxlon, maxlat))
  end

  # Formatting grabbed from ruby stdlib
  def timestamp_with_usec
    time = Time.now
    time.strftime('%Y-%m-%dT%H:%M:%S.') + format('%06d ', time.usec)
  end

  # Oh, rails, how I hate your shielding of Logger formatters from me
  def debug_msg(msg)
    "[#{timestamp_with_usec}] #{msg}"
  end
end
