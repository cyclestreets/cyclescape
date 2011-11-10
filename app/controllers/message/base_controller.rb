class Message::BaseController < ApplicationController
  before_filter :load_thread

  protected

  def load_thread
    # Need to check if user has access?
    @thread = MessageThread.find(params[:thread_id])
  end
end
