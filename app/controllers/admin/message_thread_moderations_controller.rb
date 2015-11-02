class Admin::MessageThreadModerationsController < ApplicationController
  def index
    threads = MessageThread.mod_queued.page params[:page]
    @threads = ThreadListDecorator.decorate_collection threads
  end
end
