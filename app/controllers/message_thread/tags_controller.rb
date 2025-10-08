# frozen_string_literal: true

class MessageThread::TagsController < BaseTagsController
  private

  def resource
    @resource ||= MessageThread.find params[:thread_id]
  end
end
