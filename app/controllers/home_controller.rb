class HomeController < ApplicationController
  filter_access_to :all, require: :show

  def show
  end
end
