class Admin::StatsController < ApplicationController
  def index
    @users = User.select("COUNT(*) AS count, date_trunc('month', created_at) AS month").group('month')

    @messages = Message.select("COUNT(*) AS count,
                                date_trunc('month', created_at) AS month,
                                COUNT(DISTINCT created_by_id) AS cids").group('month')

    @issues = Issue.select("COUNT(*) AS count,
                           date_trunc('month', created_at) AS month").group(:month)

    @message_types = [DeadlineMessage, LinkMessage, PhotoMessage, StreetViewMessage].
      each_with_object({}) do |klass, hsh|
      hsh[klass.model_name.human] = klass.select("COUNT(*) AS count,
                           date_trunc('month', created_at) AS month").group(:month)
    end

  end
end
