authorization do
  role :root do
    has_omnipotence
  end

  role :admin do
    includes :member
    has_permission_on :admin_groups, :group_members, :group_memberships, to: :manage
    has_permission_on :admin_users, :admin_issue_categories, to: :manage
    has_permission_on :admin_home, to: :view
  end

  role :member do
    includes :guest
    has_permission_on :dashboards, to: :show
    has_permission_on :group_members, :group_memberships do
      to :manage
      if_attribute committee_members: contains { user }
    end
    has_permission_on :group_membership_requests do
      to [:new, :create]
    end
    has_permission_on :group_membership_requests do
      to :cancel
      if_attribute user: is { user }
    end
    has_permission_on :group_membership_requests do
      to [:index, :confirm, :reject]
      if_attribute committee_members: contains { user }
    end
    has_permission_on :group_message_threads, :issue_message_threads, to: :manage
    has_permission_on :group_profiles do
      to :manage
      if_attribute committee_members: contains { user }
    end
    has_permission_on :issues, to: [:new, :create]
    has_permission_on :message_threads, :messages, to: :manage
    has_permission_on :message_thread_subscriptions, to: [:create, :destroy]
    has_permission_on :message_photos, :message_links, to: :create
    has_permission_on :user_locations, to: [:manage, :geometry]
    has_permission_on :user_profiles do
      to :manage
      if_attribute id: is { user.id }
    end
    has_permission_on :user_profiles, to: :view
  end

  role :guest do
    has_permission_on :devise_sessions, :devise_registrations, :devise_confirmations,
                      :devise_invitations, :devise_passwords, to: :manage
    has_permission_on :home, to: :show
    has_permission_on :groups, to: :view
    has_permission_on :group_profiles, to: [:view, :geometry]
    has_permission_on :issues, to: [:show, :index, :geometry, :all_geometries]
    has_permission_on :issue_message_threads, :message_threads, :messages, to: :view
    has_permission_on :site_comments, to: [:new, :create]
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
