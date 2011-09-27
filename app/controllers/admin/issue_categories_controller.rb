class Admin::IssueCategoriesController < ApplicationController
  def index
    @categories = IssueCategory.all
  end

  def new
    @category = IssueCategory.new
  end

  def create
    @category = IssueCategory.new(params[:issue_category])

    if @category.save
      redirect_to action: :index
    else
      render :new
    end
  end

  def edit
    @category = IssueCategory.find(params[:id])
  end

  def update
    @category = IssueCategory.find(params[:id])

    if @category.update_attributes(params[:issue_category])
      flash.notice = t(".category_updated")
      redirect_to action: :index
    else
      render :edit
    end
  end
end
