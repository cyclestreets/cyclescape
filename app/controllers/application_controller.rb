# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :no_disabled_users
  before_filter :set_auth_user
  before_filter :set_locale
  before_action :set_config
  around_action :set_time_zone
  before_filter :load_group_from_subdomain
  before_filter :set_page_title
  before_filter :set_last_seen_at, if: proc { |p| user_signed_in? && (session[:last_seen_at] == nil || session[:last_seen_at] < 15.minutes.ago) }
  after_filter :remember_current_group
  after_filter :store_location
  layout :set_xhr_layout
  filter_access_to :all
  helper_method :group_subdomain?
  before_filter :configure_permitted_parameters, if: :devise_controller?

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:account_update).push(:full_name, :display_name)
    devise_parameter_sanitizer.for(:sign_up).push(:full_name, :display_name)
    devise_parameter_sanitizer.for(:accept_invitation).push(:full_name, :display_name, :email)
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
        root_url(subdomain: SubdomainConstraint.subdomain(current_user.remembered_group.short_name)) + s
      else
        root_url + s
      end
    else
      if current_user.remembered_group?
        dashboard_url(subdomain: SubdomainConstraint.subdomain(current_user.remembered_group.short_name))
      else
        dashboard_url
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

  def set_locale
    I18n.locale = current_user.try(:profile).try(:locale) ||
      http_accept_language.compatible_language_from(I18n.available_locales) || I18n.default_locale
  end

  def set_auth_user
    Authorization.current_user = current_user
  end

  def set_xhr_layout
    if request.xhr? then nil else 'application' end
  end

  def load_group_from_subdomain
    if SubdomainConstraint.matches?(request)
      @current_group = Group.find_by_short_name(request.subdomain.split(".")[0])
      unless @current_group
        redirect_to root_url(subdomain: SubdomainConstraint.subdomain("www"))
      end
    end
  end

  def set_page_description(description = nil)
    @page_description = ActionView::Base.full_sanitizer.sanitize(description, tags: [])
  end

  def page_description
    @page_description
  end
  helper_method :page_description

  def set_page_image(image = nil)
    @page_image = image
  end

  def page_image
    @page_image
  end
  helper_method :page_image

  def set_page_title(title = nil, value = nil)
    key = "#{controller_path.tr("/", ".")}.#{params[:action]}.title"
    page_title = title || I18n.translate(key, (value || { default: '' }))
    app_title = @site_config.application_name
    @page_title = page_title == '' ? app_title : "#{page_title} - #{app_title}"
  end

  def page_title
    @page_title
  end
  helper_method :page_title

  def group_subdomain?(group = nil)
    !request.subdomain.blank? && request.subdomain.split(".")[0] == group
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
      respond_to do |format|
        format.html { authenticate_user! }
        format.js { render 'shared/permission_denied', status: :unauthorized }
      end
    else
      render 'shared/permission_denied', status: :unauthorized
    end
  end

  def set_flash_message(type, options = {})
    flash_key = if type == :success then :notice else :alert end
    options.reverse_merge!(scope: "#{controller_path.gsub('/', '.')}.#{action_name}")
    flash[flash_key] = I18n.t(type, options)
  end

  # A method to convert an openlayers-format bbox string into an rgeo bbox object
  def bbox_from_string(string, factory)
    return unless string
    minlon, minlat, maxlon, maxlat = string.split(',').collect(&:to_f)
    bbox = RGeo::Cartesian::BoundingBox.new(factory)
    bbox.add(factory.point(minlon, minlat)).add(factory.point(maxlon, maxlat))
  end

  def set_last_seen_at
    current_user.update(last_seen_at: Time.current)
    session[:last_seen_at] = Time.current
  end

  def set_config
    @site_config = Rails.cache.fetch(SiteConfig::KEY, expires_in: 1.week) do
      SiteConfig.first.to_struct
    end
  end

  def set_time_zone(&block)
    Time.use_zone(current_user.try(:time_zone) || @site_config.try(:time_zone) || 'London', &block)
  end
end
