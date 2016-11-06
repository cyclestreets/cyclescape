class Message::ThreadLeadersController < Message::BaseController
  filter_access_to :all, attribute_check: true, load_method: :thread

  protected

  def component
    @leader ||= ThreadLeaderMessage.new permitted_params
  end

  def permitted_params
    params.require(:thread_leader_message).permit :description, :unleading_id
  end
end
