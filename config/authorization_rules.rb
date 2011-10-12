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
    has_permission_on :issues, to: [:new, :create]
    has_permission_on :message_threads, :messages, to: :manage
    has_permission_on :group_message_threads, :issue_message_threads, to: :manage
    has_permission_on :user_profiles, to: :manage
  end

  role :guest do
    has_permission_on :devise_sessions, :devise_registrations, :devise_confirmations,
                      :devise_invitations, :devise_passwords, to: :manage
    has_permission_on :home, to: :show
    has_permission_on :issues, to: [:show, :index, :geometry, :all_geometries]
    has_permission_on :issue_message_threads, :message_threads, :messages, to: :view
    has_permission_on :user_profiles, to: :view
  end
end

privileges do
  privilege :manage do
    includes :index, :new, :create, :show, :edit, :update, :destroy
  end

  privilege :view do
    includes :index, :show
  end
end
