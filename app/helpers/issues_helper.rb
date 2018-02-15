# frozen_string_literal: true

module IssuesHelper
  def issues_list(issues, options = {})
    defaults = { partial: 'issues/compact', collection: issues, as: :issue, locals: { prefix: 'list' } }
    render defaults.merge(options)
  end
end
