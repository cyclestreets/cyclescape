# frozen_string_literal: true

class Admin::PlanningFiltersController < ApplicationController
  def index
    @planning_filters = PlanningFilter.all
  end

  def show
    filter
  end

  def edit
    filter
  end

  def new
    @filter = PlanningFilter.new
  end

  def update
    if filter.update permitted_params
      set_flash_message :success
      redirect_to action: :index
    else
      render :edit
    end
  end

  def create
    @filter = PlanningFilter.new(permitted_params)

    if filter.save
      set_flash_message :success
      redirect_to action: :index
    else
      render :new
    end
  end
  private

  def permitted_params
    params.require(:planning_filter).permit :authority, :rule
  end

  def filter
    @filter ||= PlanningFilter.find(params[:id])
  end
end
