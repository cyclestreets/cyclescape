# frozen_string_literal: true

class PlanningApplicationsController < ApplicationController
  before_action :set_planning_application, only: %i[show show_uid]
  respond_to :js, only: %i[hide unhide]

  def show; end

  def search
    @query = params[:q].strip
    planning_applications = PlanningApplication.where("uid ILIKE ?", "%#{@query}%").page params[:page]
    @planning_applications = PlanningApplicationDecorator.decorate_collection planning_applications
  end

  def show_uid
    render action: :show
  end

  def index
    permission_denied unless current_group
    @full_page = true
  end

  def all_geometries
    permission_denied unless current_group
    pas = PlanningApplication.intersects(current_group.profile.location).not_hidden.limit(50).map { |pa| planning_application_feature(pa) }
    collection = RGeo::GeoJSON::EntityFactory.new.feature_collection(pas)

    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(collection) }
    end
  end

  def hide
    planning_application = PlanningApplication.find params[:id]
    hide_vote = planning_application.hide_votes.new.tap { |pl| pl.user = current_user }
    hide_vote.save

    @planning_application = PlanningApplicationDecorator.decorate planning_application.reload

    respond_to do |format|
      format.js {}
      format.html { render :show }
    end
  end

  def unhide
    planning_application = PlanningApplication.find params[:id]
    planning_application.hide_votes.find_by(user_id: current_user.id).destroy

    @planning_application = PlanningApplicationDecorator.decorate planning_application.reload

    respond_to do |format|
      format.js {}
      format.html { render :show }
    end
  end

  protected

  def set_planning_application
    planning_application = if params[:id]
                             PlanningApplication.find(params[:id])
                           else
                             PlanningApplication.for_local_authority(params[:authority_param]).find_by!(uid: params[:uid])
                           end
    @planning_application = PlanningApplicationDecorator.decorate planning_application
  end

  def planning_application_feature(planning_application)
    planning_application.loc_feature(
      title: view_context.truncate(planning_application.title, length: 80, separator: " "),
      thumbnail: view_context.image_path("map-icons/m-misc.png"),
      anchor: [30 / 2, 42],
      url: view_context.new_planning_application_issue_path(planning_application)
    )
  end
end
