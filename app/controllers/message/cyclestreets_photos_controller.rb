# frozen_string_literal: true

class Message::CyclestreetsPhotosController < Message::BaseController
  def show
    @cyclestreets_photo = resource_class.find params[:id]
  end

  protected

  def resource_class
    CyclestreetsPhotoMessage
  end

  def permit_params
    %i[photo_url caption cyclestreets_id icon_properties loc_json]
  end
end
