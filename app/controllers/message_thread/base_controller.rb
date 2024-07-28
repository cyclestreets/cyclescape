# frozen_string_literal: true

class MessageThread::BaseController < ApplicationController
  before_action :load_thread

  protected

  def load_thread
    @thread = MessageThread.find(params[:thread_id])
    authorize @thread, :show?
    @thread
  end
end
