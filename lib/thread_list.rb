# frozen_string_literal: true

class ThreadList
  class << self
    def recent_from_groups(groups, limit = nil)
      threads = MessageThread.where(group_id: groups).approved.order_by_latest_message
      threads = threads.limit(limit) if limit
      threads
    end

    def recent_public_from_groups(groups, limit)
      recent_public.where(group_id: groups).limit(limit)
    end

    def issue_threads_from_group(group)
      from_group(group).approved.with_issue
    end

    def general_threads_from_group(group)
      from_group(group).approved.without_issue
    end

    def recent_involved_with(user, limit)
      user.involved_threads.order_by_latest_message.limit(limit)
    end

    def public_recent_involved_with(user, limit)
      recent_involved_with(user, limit).is_public
    end

    def recent_public
      MessageThread.approved.is_public.order_by_latest_message.includes(:issue, :group, :messages)
    end

    def with_upcoming_deadlines(user, limit)
      user.subscribed_threads.with_upcoming_deadlines.limit(limit)
    end

    protected

    def from_group(group)
      group.threads.includes(:messages).order_by_latest_message
    end
  end
end
