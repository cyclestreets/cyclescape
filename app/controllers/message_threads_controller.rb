class MessageThreadsController < ApplicationController
  filter_access_to :show, :edit, :update, attribute_check: true

  def index
    @threads = MessageThread.public.order("updated_at desc").page(params[:page])
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

    if @thread.update_attributes(params[:thread])
      set_flash_message(:success)
      redirect_to thread_path(@thread)
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
end
