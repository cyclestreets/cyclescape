# frozen_string_literal: true

module NewUi
  class GroupsController < BaseController
    def show
      skip_authorization
      recent_threads = if group.has_member?(current_user)
                         ThreadList.recent_from_groups(group, 10)
                       else
                         ThreadList.recent_public_from_groups(group, 10)
                       end
      @recent_threads = ThreadListDecorator.decorate_collection recent_threads.includes(:issue, :group, :latest_message)
      @user_favourites = current_user&.thread_favourites&.where(thread: recent_threads)
      @unviewed_thread_ids = MessageThread.unviewed_thread_ids(user: current_user, threads: recent_threads)
      @recent_issues = IssueDecorator.decorate_collection group.recent_issues.limit(10).includes(:created_by)
      @group = GroupDecorator.decorate @group
    end

    private

    def group
      @group ||= if params[:id]
                   Group.find(params[:id])
                 elsif current_group
                   current_group
                 end
    end
  end
end
