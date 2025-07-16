# frozen_string_literal: true

class DashboardsController < ApplicationController
  def deadlines
    skip_authorization
    cal = Icalendar::Calendar.new
    ThreadList.with_upcoming_deadlines(User.find_by(public_token: params[:public_token]), 50).each do |thread|
      thread.to_icals.each { |evt| cal.add_event(evt) }
    end
    render plain: cal.to_ical
  end

  def search
    # Ideally, this would be delegated to the different controllers.
    skip_authorization

    @query = params[:query]

    # Threads, with permission check
    # duplicated logic from authorization rules
    # as we can't paginate AND use policy
    threads = MessageThread.search(include: [:group, :issue, messages: :created_by]) do
      fulltext params[:query] do
        boost_fields id: 4, title: 2, tags_string: 1
      end
      with(:status, "approved")
      any_of do
        with(:privacy, "public")
        if current_user
          all_of do
            with(:group_id, current_user.groups.try(:ids))
            with(:privacy, "group")
          end
          all_of do
            with(:group_id, current_user.in_group_committee.map(&:id))
            with(:privacy, "committee")
          end
        end
      end
      adjust_solr_params do |sunspot_params|
        sunspot_params[:boost] = "recip(ms(NOW,latest_activity_at_dts),3.16e-11,1,1)"
      end
      paginate page: helpers.safe_search_page(params[:thread_page]), per_page: 40
    end
    @unviewed_thread_ids = MessageThread.unviewed_thread_ids(user: current_user, threads: threads.results)
    @threads = ThreadListDecorator.decorate_collection threads.results
    @user_favourites = current_user&.thread_favourites&.where(thread: threads.results)
    @latest_activity = Message.where(thread_id: @threads.map(&:id)).latest_activities

    # Issues
    issues = Issue.search(include: %i[created_by tags]) do
      fulltext params[:query] do
        boost_fields id: 4, title: 2, tags_string: 1
      end
      adjust_solr_params do |sunspot_params|
        sunspot_params[:boost] = "recip(ms(NOW,latest_activity_at_dts),3.16e-11,1,1)"
      end
      paginate page: helpers.safe_search_page(params[:issue_page]), per_page: 40
    end

    @issues = IssueDecorator.decorate_collection issues.results

    # Library Items
    library_items = Library::Item.search do
      fulltext params[:query] do
        boost_fields id: 4
      end
      paginate page: helpers.safe_search_page(params[:library_page]), per_page: 40
    end
    @library_items = Library::ItemDecorator.decorate_collection library_items.results

    # PlanningApplications
    planning_applications = PlanningApplication.search(params[:query])
                                               .includes(:users, :issue)
                                               .page params[:planning_page]
    @planning_applications = PlanningApplicationDecorator.decorate_collection planning_applications
  end
end
