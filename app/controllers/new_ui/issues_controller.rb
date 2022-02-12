# frozen_string_literal: true

module NewUi
  class IssuesController < BaseController
    def index
      @issues = Issue.preloaded.by_most_recent.page(params[:page])
      @unviewed_message_count = {}
      if current_user
        @issues.unviewed_messages(current_user).group(:id).pluck(
          :id, Arel.sql("count(*)")
        ).each_with_object(@unviewed_message_count) do |(issue_id, count), hsh|
          hsh[issue_id] = count
        end
      end
    end
  end
end
