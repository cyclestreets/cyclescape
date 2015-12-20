class Admin::StatsController < ApplicationController
  def index
    users_scope = User.all
    messages_scope = Message.all

    if @current_group
      users_ids = User.includes(:groups).where(groups: {id: 2}).ids
      users_scope = users_scope.where(id: users_ids)

      messages_ids = messages_scope.includes(:thread).where(message_threads: {group_id: 2}).ids
      messages_scope = messages_scope.where(id: messages_ids)
    end

    @users = users_scope.select("COUNT(*) AS count, date_trunc('month', users.created_at) AS month").group('month').order('month')

    @messages = messages_scope.select("COUNT(*) AS count,
                                date_trunc('month', created_at) AS month,
                                COUNT(DISTINCT created_by_id) AS cids").group('month')

    @issues = Issue.joins("LEFT OUTER JOIN planning_applications ON planning_applications.issue_id = issues.id").select(
      "COUNT(issues.*) AS count, date_trunc('month', issues.created_at) AS month,
      COUNT(planning_applications.*) AS pa").group(:month)

    @message_types = MessageComponent.descendants.
      each_with_object({}) do |klass, hsh|
      hsh[klass.model_name.human] = klass.joins(:message).select("COUNT(*) AS count,
                         date_trunc('month', messages.created_at) AS month").group(:month)
    end
  end
end
