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

  def search
    @query = params[:q]
    planning_applications = PlanningApplication.where("uid LIKE ?", "%#{@query}%").paginate(page: params[:page])
    @planning_applications = PlanningApplicationDecorator.decorate(planning_applications)
  end

  def show_uid
    planning_application = PlanningApplication.find_by_uid(params[:uid])
    @planning_application = PlanningApplicationDecorator.decorate(planning_application)
    render action: :show
  end

  protected

  def planning_application_feature(planning_application)
    planning_application.loc_feature({ thumbnail: planning_application.medium_icon_path})
  end
end
