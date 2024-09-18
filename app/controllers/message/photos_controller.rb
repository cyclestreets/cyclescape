# frozen_string_literal: true

class Message::PhotosController < ApplicationController
  before_action :photo

  def show; end

  private

  def photo
    @photo ||= PhotoMessage.find params[:id]
    authorize @photo
    @photo
  end
end
