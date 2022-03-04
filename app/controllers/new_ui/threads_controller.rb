# frozen_string_literal: true

module NewUi
  class ThreadsController < BaseController
    def index
      threads =
        if current_user
          @current_group = current_user.groups.first
          ThreadList.recent_from_groups(current_user.groups)
        else
          ThreadList.recent_public
        end

      @all = threads.where.not(issue_id: nil).page(1)
      @popular =
        if @current_group
          @current_group.threads.ordered_by_nos_of_messages.page(1)
        else
          MessageThread.ordered_by_nos_of_messages.page(1)
        end
      @mine = threads.where(created_by: current_user).page(params[:my_issues_page])
      @favourite = current_user.favourite_threads.page(1)

      @unviewed_message_count = {}
      if current_user
        @current_group = current_user.groups.first
        MessageThread.where(id: @all.map(&:id) + @popular.map(&:id) + @mine.map(&:id) + @favourite.map(&:id)).unviewed_message_counts(current_user).each_with_object(@unviewed_message_count) do |(issue_id, count), hsh|
          hsh[issue_id] = count
        end
      end
    end
  end
end
