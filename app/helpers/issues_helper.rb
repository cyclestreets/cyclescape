module IssuesHelper
  def issues_list(issues, options = {})
    defaults = {partial: "issues/compact", collection: issues, as: :issue}
    render defaults.merge(options)
  end
end
