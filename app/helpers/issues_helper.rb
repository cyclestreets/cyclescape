# frozen_string_literal: true

module IssuesHelper
  def issues_list(issues, options = {})
    defaults = { partial: "issues/compact", collection: issues, as: :issue, locals: { prefix: "list" }, cached: true }
    render defaults.merge(options)
  end
end
