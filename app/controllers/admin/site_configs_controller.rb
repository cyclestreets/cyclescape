# frozen_string_literal: true

class Admin::SiteConfigsController < ApplicationController
  before_action :set_site_config, only: %i[show edit update destroy]
  # GET /site_configs/1
  def show; end

  # GET /site_configs/1/edit
  def edit; end

  def update
    if @live_site_config.update(site_config_params)
      redirect_to admin_site_config_path, notice: "Site config was successfully updated."
    else
      render :edit
    end
  end

  private

  def set_site_config
    @live_site_config = SiteConfig.first
  end

  def site_config_params
    params.require(:site_config).permit(
      :logo, :small_logo, :application_name, :domain,
      :funder_name_footer1, :funder_url_footer1, :funder_image_footer1,
      :funder_name_footer2, :funder_url_footer2, :funder_image_footer2,
      :funder_name_footer3, :funder_url_footer3, :funder_image_footer3,
      :funder_name_footer4, :funder_url_footer4, :funder_image_footer4,
      :funder_name_footer5, :funder_url_footer5, :funder_image_footer5,
      :funder_name_footer6, :funder_url_footer6, :funder_image_footer6,
      :nowhere_location,
      :tile_server1_name, :tile_server1_url, :tile_server1_type, :tile_server1_options,
      :tile_server2_name, :tile_server2_url, :tile_server2_type, :tile_server2_options,
      :tile_server3_name, :tile_server3_url, :tile_server3_type, :tile_server3_options,
      :email_domain,
      :facebook_link, :twitter_link,
      :default_locale, :timezone,
      :ga_account_id, :ga_base_domain,
      :default_email, :geocoder_url,
      :geocoder_key, :blog_url, :blog_user_guide_url, :admin_email,
      :blog_about_url, :google_street_view_api_key, :planit_api_key
    )
  end
end
