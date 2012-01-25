class HomeController < ApplicationController
  filter_access_to :all, require: :show

  def show
    latest_threads = ThreadList.recent_public.limit(6)
    @latest_threads = ThreadListDecorator.decorate(latest_threads)
  end
end
