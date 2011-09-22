class IssuesController < ApplicationController

  before_filter :authenticate_user!, only: [:new, :create]
  
  def index
    @issues = Issue.all
  end

  def show
    @issue = Issue.find(params[:id])
  end

  def new
    @issue = Issue.new
  end

  def create
    @issue = Issue.new(params[:issue])
    @issue.created_by_id = current_user.id

    if @issue.save
      redirect_to action: :index
    else
      render :new
    end
  end

end
