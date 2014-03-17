class ConfirmationsController < Devise::ConfirmationsController
  # Copy the method here, otherwise rails breaks when trying to find the template
  def new
    build_resource({})
  end

  protected

  # The path used after confirmation.
  def after_confirmation_path_for(resource_name, resource)
    user_locations_path(protocol: 'http')
  end
end
