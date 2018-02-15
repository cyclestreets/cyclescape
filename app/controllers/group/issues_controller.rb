# frozen_string_literal: true

# Note inheritance
class Group::IssuesController < IssuesController
  filter_access_to [:edit, :update, :destroy], attribute_check: true, context: :issues
  filter_access_to :all, context: :issues

  def index
    set_page_title t('group.issues.index.title', group_name: current_group.name)

    issues = Issue.preloaded.intersects(current_group.profile.location).by_most_recent.page(params[:page])

    popular_issues = Issue.intersects(current_group.profile.location).by_score.preloaded.page(params[:pop_issues_page])

    @issues = IssueDecorator.decorate_collection issues
    @popular_issues = IssueDecorator.decorate_collection popular_issues
    @start_location = index_start_location
  end

  private

  def geom_issue_scope
    Issue.intersects(current_group.profile.location)
  end
end
