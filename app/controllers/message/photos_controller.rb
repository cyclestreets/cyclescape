# frozen_string_literal: true

class Message::PhotosController < ApplicationController
  def show
    @photo = PhotoMessage.find params[:id]
  end
end
