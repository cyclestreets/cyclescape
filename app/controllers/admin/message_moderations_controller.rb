class Admin::MessageModerationsController < ApplicationController
  def index
    @messages = Message.mod_queued.page params[:page]
  end
end
