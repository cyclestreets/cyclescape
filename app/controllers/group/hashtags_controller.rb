class Group::HashtagsController < ApplicationController
  before_filter :load_group
  filter_access_to :all, attribute_check: true, model: Group

  def index
    @hashtags = @group.hashtags
  end

  def show
    if (hashtag = @group.hashtags.includes(messages: :thread).find_by_name(params[:name]))
      @messages = hashtag.messages.page(params[:page])

      threads = @messages.map(&:thread).compact
      @unviewed_thread_ids = MessageThread.unviewed_thread_ids(user: current_user, threads: threads)
    end
  end

  protected

  def load_group
    @group = current_group
  end
end
