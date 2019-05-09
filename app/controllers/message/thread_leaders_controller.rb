# frozen_string_literal: true

class Message::ThreadLeadersController < Message::BaseController
  filter_access_to :all, attribute_check: true, load_method: :thread

  protected

  def resource_class
    ThreadLeaderMessage
  end

  def permit_params
    %i[description unleading_id]
  end
end
