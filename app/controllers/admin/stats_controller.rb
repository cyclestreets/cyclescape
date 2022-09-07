# frozen_string_literal: true

class Admin::StatsController < ApplicationController
  def issues_untagged
    @issues_untagged = Issue.joins(:threads).where(
      <<~SQL
        not exists (select 1 from issue_tags where issue_tags.issue_id = issues.id)
        and not exists (select 1 from message_thread_tags where message_thread_tags.thread_id = message_threads.id)
      SQL
    ).distinct
  end

  def issues_with_multiple_threads
    multiple_ids = Issue.joins(:threads).group(:id).having("count(*) > 1").ids
    multiple_tag_ids = Tag.joins(:issues).where(issues: {id: multiple_ids}).ids
    uniq_multiple_tag_ids = Tag.where(id: multiple_tag_ids).joins(:issues, :threads).group(:id).having("count(*) = 1").ids
    already_uniq = Issue.joins(:tags).where(id: multiple_ids, tags: {id: uniq_multiple_tag_ids}).ids
    @issues_with_multiple_threads = Issue.where(id: multiple_ids - already_uniq).left_joins(:tags).group(:id, :title).select(
      "issues.id, title, json_agg(tags.name) as tag_names"
    )
  end

  def index
    users_scope = User.all
    messages_scope = Message.all

    if @current_group
      users_ids = User.includes(:groups).where(groups: { id: 2 }).ids
      users_scope = users_scope.where(id: users_ids)

      messages_ids = messages_scope.includes(:thread).where(message_threads: { group_id: 2 }).ids
      messages_scope = messages_scope.where(id: messages_ids)
    end

    @users = users_scope.select("COUNT(*) AS count, date_trunc('month', users.created_at) AS month").group("month").order("month")

    @messages = messages_scope.select("COUNT(*) AS count,
                                date_trunc('month', created_at) AS month,
                                COUNT(DISTINCT created_by_id) AS cids").group("month")

    @issues = Issue.joins("LEFT OUTER JOIN planning_applications ON planning_applications.id = issues.planning_application_id").select(
      "COUNT(issues.*) AS count, date_trunc('month', issues.created_at) AS month,
      COUNT(planning_applications.*) AS pa"
    ).group(:month)

    @message_types = MessageComponent.descendants
                                     .each_with_object({}) do |klass, hsh|
      hsh[klass.model_name.human] = klass.joins(:message).select("COUNT(*) AS count,
                         date_trunc('month', messages.created_at) AS month").group(:month)
    end
  end
end
