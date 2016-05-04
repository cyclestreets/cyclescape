class SearchUpdater
  def self.queue
    :search_updates
  end

  # Call +method+ with *args on ourself
  def self.perform(method, *args)
    send(method, *args)
  end

  # cheekily added, we have too many queues, low, medium and high priority is enough
  def self.update_relevant_planning_applications
    planning_filters = PlanningFilter.all

    PlanningApplication.transaction do
      PlanningApplication.find_each do |pa|
        new_relavant = pa.calculate_relavant(planning_filters)
        if pa.relevant != new_relavant
          pa.update(relevant: new_relavant)
        end
      end
    end
  end

  def self.update_type(item, type)
    Resque.enqueue(SearchUpdater, type, item.id)
  end

  def self.process_thread(thread_id)
    thread = MessageThread.find(thread_id)
    Sunspot.index thread
    Sunspot.index thread.issue if thread.issue
    Sunspot.commit
  end

  def self.process_issue(issue_id)
    Sunspot.index Issue.find(issue_id)
    Sunspot.commit
  end
end
