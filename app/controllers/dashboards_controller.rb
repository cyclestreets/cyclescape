class DashboardsController < ApplicationController
  def show
    @user = current_user
    @groups = @user.groups

    @relevant_issues = IssueDecorator.decorate_collection(current_user.issues_near_locations.order('updated_at DESC').limit(12).preloaded)

    subscribed_threads = current_user.subscribed_threads.order_by_latest_message.
      limit(12).includes(:issue, latest_message: [:component, :created_by])
    @subscribed_threads = ThreadListDecorator.decorate_collection subscribed_threads

    group_threads = ThreadList.recent_from_groups(current_user.groups, 8).includes(:group)
    @group_threads = ThreadListDecorator.decorate_collection group_threads

    deadline_threads = ThreadList.with_upcoming_deadlines(current_user, 12).includes(:issue, :latest_message)
    @deadline_threads = ThreadListDecorator.decorate_collection deadline_threads

    prioritised_threads = current_user.prioritised_threads.order('priority desc').
      order_by_latest_message.limit(20).includes(:issue, latest_message: [:component, :created_by])
    @prioritised_threads = ThreadListDecorator.decorate_collection(prioritised_threads)

    planning_applications = current_user.planning_applications_near_locations.ordered
      .not_hidden.page params[:planning_page]
    @planning_applications = PlanningApplicationDecorator.decorate_collection planning_applications.relevant.includes(:users)
  end

  def deadlines
    cal = Icalendar::Calendar.new
    ThreadList.with_upcoming_deadlines(current_user, 20).each do |thread|
      thread.to_icals.each { |evt| cal.add_event(evt) }
    end
    render text: cal.to_ical
  end

  def search
    # Ideally, this would be delegated to the different controllers.

    @query = params[:query]

    # Threads, with permission check
    # duplicated logic from authorization rules
    # as we can't paginate AND use permitted_to
    threads = MessageThread.search(include: [:group, :issue, messages: :created_by]) do
      fulltext params[:query] do
        boost_fields title: 2.0
        boost_fields tags_string: 1.0
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
            with(:group_id, current_user.in_group_committee.map(&:id))
            with(:privacy, 'committee')
          end
        end
      end
      adjust_solr_params do |sunspot_params|
        sunspot_params[:boost] = 'recip(ms(NOW,latest_activity_at_dts),3.16e-11,1,1)'
      end
      paginate page: params[:thread_page], per_page: 40
    end
    @threads = ThreadListDecorator.decorate_collection threads.results

    # Issues
    issues = Issue.search(include: [:created_by, :tags]) do
      fulltext params[:query] do
        boost_fields title: 2.0
        boost_fields tags_string: 1.0
      end
      adjust_solr_params do |sunspot_params|
        sunspot_params[:boost] = 'recip(ms(NOW,latest_activity_at_dts),3.16e-11,1,1)'
      end
      paginate page: params[:issue_page], per_page: 40
    end

    @issues = IssueDecorator.decorate_collection issues.results

    # Library Items
    library_items = Library::Item.search do
      fulltext params[:query]
      paginate page: params[:library_page], per_page: 40
    end
    @library_items = Library::ItemDecorator.decorate_collection library_items.results

    # Users? Groups?
  end
end
