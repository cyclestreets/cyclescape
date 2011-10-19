class User::LocationsController < ApplicationController
  def index
  end

  def new
    @location = current_user.locations.new
  end
end
