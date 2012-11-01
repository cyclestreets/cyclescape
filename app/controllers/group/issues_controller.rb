# Note inheritance
class Group::IssuesController < IssuesController
  filter_access_to :all, context: :issues

  def index
    set_page_title t("group.issues.index.title", group_name: current_group.name)

    issues = Issue.intersects(current_group.profile.location).by_most_recent.paginate(page: params[:page])
    popular_issues = Issue.intersects(current_group.profile.location).plusminus_tally(start_at: 8.weeks.ago, at_least: 1)

    @issues = IssueDecorator.decorate(issues)
    @popular_issues = IssueDecorator.decorate(popular_issues)
    @start_location = index_start_location
  end
end
