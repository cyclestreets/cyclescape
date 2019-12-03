# frozen_string_literal: true

class Message::PhotosController < ApplicationController
  before_action :photo
  filter_access_to :all, attribute_check: true

  def show; end

  private

  def photo
    @photo ||= PhotoMessage.find params[:id]
  end
end
