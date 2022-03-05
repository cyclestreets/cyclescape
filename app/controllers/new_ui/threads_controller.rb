# frozen_string_literal: true

module NewUi
  class ThreadsController < BaseController
    def index
      if current_user
        @current_group = current_user.groups.first
        threads = ThreadList.recent_from_groups(current_user.groups)
        @all = threads.where.not(issue_id: nil).page(1)
        @popular = @current_group.threads.where.not(issue_id: nil).ordered_by_nos_of_messages.page(1)
        @mine = threads.where(created_by: current_user).page(1)
        @favourite = current_user.favourite_threads.page(1)

        @unviewed_message_count = {}
        @current_group = current_user.groups.first
        ids = @all.map(&:id) + @popular.map(&:id) + @mine.map(&:id) + @favourite.map(&:id)
        MessageThread
          .where(id: ids).unviewed_message_counts(current_user)
          .each_with_object(@unviewed_message_count) do |(issue_id, count), hsh|
          hsh[issue_id] = count
        end
      else
        threads = ThreadList.recent_public
        @all = threads.where.not(issue_id: nil).page(1)
        @popular = MessageThread.none
        @mine = MessageThread.none
        @favourite = MessageThread.none
        @unviewed_message_counts = {}
      end
    end
  end
end
