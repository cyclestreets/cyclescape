class MessageThreadsController < ApplicationController
  def index
    @threads = MessageThread.all
  end

  def new
    @thread = MessageThread.new
  end

  def create
    @thread = MessageThread.new(params[:thread])
  end

  def show
    @thread = MessageThread.find(params[:id])
    @messages = @thread.messages
  end

  def edit
    @thread = MessageThread.find(params[:id])
  end

  def update
    @thread = MessageThread.find(params[:id])

    if @thread.update_attributes
      redirect_to action: :index
    else
      render :edit
    end
  end
end
