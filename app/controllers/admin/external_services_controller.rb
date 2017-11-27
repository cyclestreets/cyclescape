class Admin::ExternalServicesController < ApplicationController
  def index
    @external_services = ExternalService.all
  end

  def new
    @external_service = ExternalService.new
  end

  def create
    @external_service = ExternalService.new(permitted_params)
    puts @external_service

    if @external_service.save
      set_flash_message(:success)
      redirect_to action: :index
    else
      render :new
    end
  end

  def edit
    external_service
  end

  def update
    if external_service.update permitted_params
      set_flash_message :success
      redirect_to action: :index
    else
      render :edit
    end
  end

  protected

  def permitted_params
    params.require(:external_service).permit :name, :short_name
  end

  def external_service
    @external_service ||= ExternalService.find params[:id]
  end
end
