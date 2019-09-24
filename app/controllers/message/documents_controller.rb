# frozen_string_literal: true

class Message::DocumentsController < Message::BaseController
  def show
    @document = resource_class.find params[:id]
  end

  protected

  def resource_class
    DocumentMessage
  end

  def permit_params
    
  end
end
