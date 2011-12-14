class MessageThreadsController < ApplicationController
  MESSAGE_COMPONENTS = [PhotoMessage]
  helper_method :message_components

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
    @issue = @thread.issue if @thread.issue
    @messages = @thread.messages.all
    @new_message = @thread.messages.build
    @subscribers = @thread.subscribers
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

  def destroy
    load_thread

    if @thread.destroy
      set_flash_message(:success)
      redirect_to threads_path
    else
      set_flash_message(:failure)
      redirect_to @thread
    end
  end

  protected

  def load_thread
    @thread = MessageThread.find(params[:id])
  end

  def message_components
    MESSAGE_COMPONENTS
  end
end
