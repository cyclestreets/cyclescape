class PlanningApplicationsController < ApplicationController
  before_filter :set_planning_application, on: [:show, :show_uid, :geometry]

  def show
  end

  def geometry
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(planning_application_feature(@planning_application)) }
    end
  end

  def search
    @query = params[:q]
    planning_applications = PlanningApplication.where("uid LIKE ?", "%#{@query}%").paginate(page: params[:page])
    @planning_applications = PlanningApplicationDecorator.decorate(planning_applications)
  end

  def show_uid
    render action: :show
  end

  def hide
    if @planning_application.planning_application.hide!
      set_flash_message(:success)
    else
      set_flash_message(:failure)
    end
    head :no_content #should be refresh
  end

  protected

  def set_planning_application
    planning_application = if params[:id]
                             PlanningApplication.find(params[:id])
                           else
                             PlanningApplication.find_by_uid(params[:uid])
                           end
    @planning_application = PlanningApplicationDecorator.decorate(planning_application)
  end

  def planning_application_feature(planning_application)
    planning_application.loc_feature({ thumbnail: planning_application.medium_icon_path})
  end
end
