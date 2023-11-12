# frozen_string_literal: true

class Message::CyclestreetsPhotosController < ApplicationController
  def show
    @cyclestreets_photo = CyclestreetsPhotoMessage.find params[:id]
    authorize @cyclestreets_photo
  end
end
