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
      redirect_to @site_config, notice: 'Site config was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /site_configs/1
  def update
    if @site_config.update(site_config_params)
      redirect_to @site_config, notice: 'Site config was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /site_configs/1
  def destroy
    @site_config.destroy
    redirect_to site_configs_url, notice: 'Site config was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_site_config
      @site_config = SiteConfig.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def site_config_params
      params.require(:site_config).permit(
        :logo_uuid, :title_tag, :domain, :footer1_uuid, :footer2_uuid,
        :footer3_uuid, :nowhere_location,
        :tile_server1_name, :tile_server2_name, :tile_server3_name,
        :tile_server1_url, :tile_server2_url, :tile_server3_url,
        :footer_html, :header_html,
        :default_locale, :timezone,
        :ga_account_id, :ga_base_domain,
        :default_email, :devise_email, :geocoder_url,
        :application_name)
    end
end
