# frozen_string_literal: true

class ConfirmationsController < Devise::ConfirmationsController
  protected

  # The path used after confirmation.
  def after_confirmation_path_for(_resource_name, _resource)
    current_user_locations_path
  end
end
