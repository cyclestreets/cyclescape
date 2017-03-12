class HomeController < ApplicationController
  filter_access_to :all, require: :show

  def show
    latest_threads = ThreadList.recent_public.limit(6).includes(messages: :created_by)
    @latest_threads = ThreadListDecorator.decorate_collection(latest_threads)
    @unviewed_thread_ids = latest_threads.unviewed_for(current_user).ids.uniq
  end
end
