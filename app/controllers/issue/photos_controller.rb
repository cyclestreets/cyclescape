# frozen_string_literal: true

class Issue::PhotosController < ApplicationController
  def show
    @issue = Issue.find params[:issue_id]
    if @issue.photo.nil?
      fail ActionController::RoutingError.new('Not Found')
    end
  end
end
