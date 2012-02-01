class Issue::PhotosController < ApplicationController
  def show
    @issue = Issue.find(params[:issue_id])
  end
end