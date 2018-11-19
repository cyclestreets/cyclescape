module Route
  class MembershipApi < Base
    params do
      requires :email, type: String, desc: "Email address of the new member"
      requires :role, type: String, values: GroupMembership::ALLOWED_ROLES, desc: "The role the newly created membership will be"
      requires :full_name, type: Symbol
      requires :group, type: String, desc: "The subdomain or short name of the group"
    end

    post :membership do
      user = User.find_by(api_key: params[:api_key])
      error! "Invalid API KEY", 400 unless user
      group = Group.find_by(short_name: params[:group])
      error! 'Given group not found', 404 unless group
      error! "Not a committee member", 400 unless user.memberships.committee.where(group: group).exists?

      user = User.find_or_initialize_by(
        email: params[:email],
        full_name: params[:full_name]
      )

      membership = group.memberships.create!(
        user: user,
        role: params[:role]
      )
      if membership.user.accepted_or_not_invited?
        Notifications.added_to_group(membership).deliver_later
      end
      {
        status: "success",
        data: nil
      }
    end
  end
end
