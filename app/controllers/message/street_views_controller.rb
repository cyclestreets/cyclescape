# frozen_string_literal: true

class Message::StreetViewsController < Message::BaseController
  protected

  def component
    super.tap do |svm|
      svm.set_location params[:street_view_message_location_string]
    end
  end

  def resource_class
    StreetViewMessage
  end

  def permit_params
    %i[caption heading pitch]
  end
end
