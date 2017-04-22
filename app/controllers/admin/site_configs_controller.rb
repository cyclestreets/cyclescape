class Admin::SiteConfigsController < ApplicationController
  before_action :set_site_config, only: [:show, :edit, :update, :destroy]

  # GET /site_configs
  def index
    @site_configs = SiteConfig.all
  end

  # GET /site_configs/1
  def show
  end

  # GET /site_configs/new
  def new
    @site_config = SiteConfig.new
  end

  # GET /site_configs/1/edit
  def edit
  end

  # POST /site_configs
  def create
    @site_config = SiteConfig.new(site_config_params)

    if @site_config.save
      redirect_to [:admin, @site_config], notice: 'Site config was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /site_configs/1
  def update
    if @site_config.update(site_config_params)
      redirect_to [:admin, @site_config], notice: 'Site config was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /site_configs/1
  def destroy
    @site_config.destroy
    redirect_to admin_site_configs_url, notice: 'Site config was successfully destroyed.'
  end

  private
  def set_site_config
    @site_config = SiteConfig.find(params[:id])
  end

  def site_config_params
    params.require(:site_config).permit(
      :logo, :application_name, :domain,
      :funder_name_footer1, :funder_url_footer1, :funder_image_footer1,
      :funder_name_footer2, :funder_url_footer2, :funder_image_footer2,
      :funder_name_footer3, :funder_url_footer3, :funder_image_footer3,
      :funder_name_footer4, :funder_url_footer4, :funder_image_footer4,
      :funder_name_footer5, :funder_url_footer5, :funder_image_footer5,
      :funder_name_footer6, :funder_url_footer6, :funder_image_footer6,
      :nowhere_location,
      :tile_server1_name, :tile_server1_url, :tile_server2_name,
      :tile_server2_name, :tile_server2_url, :tile_server2_name,
      :tile_server3_name, :tile_server3_url, :tile_server2_name,
      :facebook_link, :twitter_link,
      :header_html, :footer_links_html,
      :default_locale, :timezone,
      :ga_account_id, :ga_base_domain,
      :default_email, :geocoder_url,
      :geocoder_key)
  end
end
