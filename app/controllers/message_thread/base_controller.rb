class MessageThread::BaseController < ApplicationController
  before_filter :load_thread

  protected

  def load_thread
    @thread = MessageThread.find(params[:thread_id])
  end
end
