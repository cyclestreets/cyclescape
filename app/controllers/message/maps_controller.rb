class Message::MapsController < Message::BaseController
  protected

  def component
    @street_view ||= MapMessage.new(permitted_params)
  end

  def permitted_params
    params.require(:map_message).permit :caption, :loc_json
  end
end
