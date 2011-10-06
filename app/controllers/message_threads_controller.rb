class MessageThreadsController < ApplicationController
  def index
    @threads = MessageThread.all
  end

  def new
    @thread = MessageThread.new
    @message = @thread.messages.build
  end

  def create
    @thread = MessageThread.new(params[:thread].merge(created_by: current_user))
    @message = @thread.messages.build(params[:message].merge(created_by: current_user))

    if @thread.save
      redirect_to action: :show, id: @thread
    else
      render :new
    end
  end

  def show
    load_thread
    @messages = @thread.messages
    @new_message = @thread.messages.build
  end

  def edit
    load_thread
  end

  def update
    load_thread

    if @thread.update_attributes
      redirect_to action: :index
    else
      render :edit
    end
  end

  protected

  def load_thread
    @thread = MessageThread.find(params[:id])
  end
end
