class PagesController < ApplicationController
  def show
    render File.basename(params[:page].to_s)
  end
end
