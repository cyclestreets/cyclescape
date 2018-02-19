class Message::StreetViewsController < Message::BaseController
  protected

  def component
    @component ||= StreetViewMessage.new(permitted_params).tap do |svm|
      svm.set_location params[:street_view_message_location_string]
    end
  end

  def permitted_params
    params.require(:street_view_message).permit :caption, :heading, :pitch
  end
end
