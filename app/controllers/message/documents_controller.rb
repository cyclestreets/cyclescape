# frozen_string_literal: true

class Message::DocumentsController < ApplicationController
  def show
    @document = DocumentMessage.find params[:id]
    authorize @document
  end
end
