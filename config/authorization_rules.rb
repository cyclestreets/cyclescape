authorization do
  role :root do
    has_omnipotence
  end

  role :admin do
    includes :member
    has_permission_on :admin_groups, :group_members, :group_memberships, to: :manage
  end

  role :member do
    includes :guest
    has_permission_on :group_members, :group_memberships do
      to :manage
      # Don't know why this always denies permission
      #if_attribute committee_members: contains { user }
    end
    has_permission_on :dashboards, to: :show
  end

  role :guest do
    has_permission_on :devise_sessions, :devise_registrations, :devise_confirmations,
                      :devise_invitations, to: :manage
    has_permission_on :home, to: :show
  end
end

privileges do
  privilege :manage do
    includes :index, :new, :create, :show, :edit, :update, :destroy
  end
end
