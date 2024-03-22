# frozen_string_literal: true

class Issue::PhotosController < ApplicationController
  skip_before_action :block_guests, on: %i[show]

  def show
    skip_authorization
    @issue = Issue.find params[:issue_id]
    raise ActionController::RoutingError, "Not Found" if @issue.photo.nil?
  end
end
