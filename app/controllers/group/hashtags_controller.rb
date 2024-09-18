# frozen_string_literal: true

class Group
  class HashtagsController < ApplicationController
    before_action :load_group

    def index
      skip_authorization
      @hashtags = @group.hashtags
    end

    def show
      skip_authorization
      hashtag = @group.hashtags.includes(messages: :thread).find_by_name(params[:name])
      return unless hashtag

      @messages = hashtag.messages.ordered.page(params[:page])

      threads = @messages.map(&:thread).compact
      @unviewed_thread_ids = MessageThread.unviewed_thread_ids(user: current_user, threads: threads)
    end

    protected

    def load_group
      @group = current_group
    end
  end
end
