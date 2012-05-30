class PlanningApplicationsController < ApplicationController
  def show
    planning_application = PlanningApplication.find(params[:id])
    @planning_application = PlanningApplicationDecorator.decorate(planning_application)
  end

  def geometry
    planning_application = PlanningApplication.find(params[:id])
    @planning_application = PlanningApplicationDecorator.decorate(planning_application)
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(planning_application_feature(@planning_application)) }
    end
  end

  protected

  def planning_application_feature(planning_application)
    planning_application.loc_feature({ thumbnail: planning_application.medium_icon_path})
  end
end
