class ConfirmationsController < Devise::ConfirmationsController
  protected

  # The path used after confirmation.
  def after_confirmation_path_for(resource_name, resource)
    user_locations_path(:protocol => 'http')
  end
end
