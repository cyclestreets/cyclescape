class DashboardsController < ApplicationController
  def show
    @user = current_user
    @groups = @user.groups

    @relevant_issues = IssueDecorator.decorate_collection(current_user.issues_near_locations.order('updated_at DESC').limit(12).includes(:created_by, :tags))

    subscribed_threads = current_user.subscribed_threads.order_by_latest_message.
      limit(12).includes(:issue, latest_message: [:component, :created_by])
    @subscribed_threads = ThreadListDecorator.decorate_collection subscribed_threads

    group_threads = ThreadList.recent_from_groups(current_user.groups, 8).includes(:group, issue: :tags).references(:group)
    @group_threads = ThreadListDecorator.decorate_collection group_threads

    deadline_threads = ThreadList.with_upcoming_deadlines(current_user, 12).includes(:issue)
    @deadline_threads = ThreadListDecorator.decorate_collection deadline_threads

    prioritised_threads = current_user.prioritised_threads.order('priority desc').
      order_by_latest_message.limit(20).includes(:issue, latest_message: [:component, :created_by])
    @prioritised_threads = ThreadListDecorator.decorate_collection(prioritised_threads)

    planning_applications = current_user.planning_applications_near_locations.ordered
      .not_hidden.page params[:planning_page]
    @planning_applications = PlanningApplicationDecorator.decorate_collection planning_applications
  end

  def search
    # Ideally, this would be delegated to the different controllers.

    @query = params[:query]

    # Threads, with permission check
    # duplicated logic from authorization rules
    # as we can't paginate AND use permitted_to
    threads = MessageThread.search do
      fulltext params[:query] do
        boost_fields title: 2.0
      end
      with(:status, 'approved')
      any_of do
        with(:privacy, 'public')
        if current_user
          all_of do
            with(:group_id, current_user.groups.try(:ids))
            with(:privacy, 'group')
          end
          all_of do
            with(:group_id, current_user.in_group_committee.try(:ids))
            with(:privacy, 'committee')
          end
        end
      end
      paginate page: params[:thread_page], per_page: 50
    end
    @threads = ThreadListDecorator.decorate_collection threads.results

    # Issues
    issues = Issue.search do
      fulltext params[:query] do
        boost_fields title: 2.0
      end
      paginate page: params[:issue_page], per_page: 50
    end

    @issues = IssueDecorator.decorate_collection issues.results

    # Library Items
    library_items = Library::Item.search do
      fulltext params[:query]
      paginate page: params[:library_page], per_page: 50
    end
    @library_items = Library::ItemDecorator.decorate_collection library_items.results

    # Users? Groups?
  end
end
