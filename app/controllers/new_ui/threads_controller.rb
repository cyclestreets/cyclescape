# frozen_string_literal: true

module NewUi
  class ThreadsController < BaseController
    def index
      @current_group = current_user.groups.first
      unviewed_message_count
    end

    private

    def threads_scope
      return @_scope if @_scope
      @_scope = MessageThread.approved.includes(:created_by, :issue, group: :profile)
      @_scope ||=
        if params[:cat] && params[:cat] == ["administration"]
          @_scope.where(group: @current_group).without_issue
        else
          issue_ids = Issue.preloaded.intersects(current_group.profile.location).ids
          @_scope.where(issue_id: issue_ids)
        end
    end

    def unviewed_message_count
      return @unviewed_message_count if @unviewed_message_count

      @unviewed_message_count = {}
      MessageThread
        .where(id: all_thread_tabs.map(&:id)).unviewed_message_counts(current_user)
        .each_with_object(@unviewed_message_count) do |(issue_id, count), hsh|
        hsh[issue_id] = count
      end
    end

    def all_thread_tabs
      all + popular + mine + favourite
    end

    def all
      @all ||=
        if params[:all_page] || !request.xhr?
          threads_scope.order_by_latest_message.page(params[:all_page])
        else
          MessageThread.none.page(1)
        end
    end

    def popular
      @popular ||=
        if !request.xhr? || params[:pop_page]
          threads_scope.ordered_by_nos_of_messages.page(params[:pop_page])
        else
          MessageThread.none.page(1)
        end
    end

    def mine
      @mine ||=
        if !request.xhr? || params[:mine_page]
          threads_scope.where(created_by: current_user).page(params[:mine_page])
        else
          MessageThread.none.page(1)
        end
    end

    def favourite
      @favourite ||=
        if !request.xhr? || params[:fav_page]
          threads_scope.where(id: current_user.favourite_threads.ids).order_by_latest_message.page(params[:fav_page])
        else
          MessageThread.none.page(1)
        end
    end
  end
end
