# frozen_string_literal: true

module Admin
  class MessageModerationsController < BaseController
    def index
      @messages = Message.mod_queued.page params[:page]
    end
  end
end
