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
    @issue = current_user.issues.new(params[:issue])

    if @issue.save
      redirect_to action: :index
    else
      render :new
    end
  end

end
