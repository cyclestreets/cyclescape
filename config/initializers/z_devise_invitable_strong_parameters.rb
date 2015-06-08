# to be deleted when with rails 4 upgrade
Devise::InvitationsController.class_eval do
  def update_resource_params
    params.require(resource_name).permit(
      :invitation_token,
      :password,
      :password_confirmation,
      :full_name,
      :display_name,
      :email
    )
  end
end
