# frozen_string_literal: true

class Message::MapsController < Message::BaseController
  protected

  def resource_class
    MapMessage
  end

  def permit_params
    %i[caption loc_json]
  end
end
