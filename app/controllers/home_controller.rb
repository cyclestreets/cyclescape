class HomeController < ApplicationController
  filter_access_to :all, require: :show

  def show
    latest_threads = ThreadList.recent_public.limit(6).includes(:issue, :group)
    @latest_threads = ThreadListDecorator.decorate(latest_threads)
  end
end
