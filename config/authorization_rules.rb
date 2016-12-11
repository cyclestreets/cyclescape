authorization do
  role :root do
    has_omnipotence
  end

  role :admin do
    includes :member
    has_permission_on :admin_groups, :group_members, :group_memberships, :group_membership_requests, :group_profiles, :group_prefs, to: :manage
    has_permission_on :group_requests do
      to [:index, :review, :confirm, :reject, :destroy]
    end
    has_permission_on :admin_users, to: [:manage, :approve]
    has_permission_on :admin_user_locations, to: [:manage, :geometry, :combined_geometry]
    has_permission_on :admin_home, to: :view
    has_permission_on :admin_message_moderations, to: :view
    has_permission_on :admin_stats, to: :view
    has_permission_on :admin_planning_filters, to: :manage
    has_permission_on :issues, to: [:edit, :update, :destroy]
    has_permission_on :library_documents, :library_notes, to: [:edit, :update]
    has_permission_on :message_threads, :group_message_threads, :issue_message_threads, to: :manage
    has_permission_on :messages, to: [:censor, :approve, :reject]
    has_permission_on :site_comments, to: :manage
    has_permission_on :user_prefs, :user_profiles, to: :manage
    has_permission_on :users, to: [:view_profile, :view_full_name]
  end

  role :member do
    includes :guest
    has_permission_on :dashboards, to: [:show]
    has_permission_on :group_requests do
      to [:new, :create]
    end
    has_permission_on :group_requests do
      to :cancel
      if_attribute user: is { user }
    end
    has_permission_on :group_members, :group_memberships do
      to :manage
      if_attribute committee_members: contains { user }
    end
    has_permission_on :group_potential_members do
      to [:new, :create]
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
      to [:index, :review, :confirm, :reject]
      if_attribute committee_members: contains { user }
    end
    has_permission_on :group_prefs do
      to :manage
      if_attribute committee_members: contains { user }
    end
    has_permission_on :group_profiles do
      to :manage
      if_attribute committee_members: contains { user }
    end
    has_permission_on :group_message_moderations do
      to :index
      if_attribute committee_members: contains { user }
    end

    has_permission_on :issues, to: [:new, :create, :vote_up, :vote_down, :vote_clear]
    has_permission_on :issues do
      to [:edit, :update]
      if_attribute created_by: is { user }
    end
    has_permission_on :issue_tags, to: [:update]
    has_permission_on :messages, to: [:new, :create]
    has_permission_on :message_library_notes, to: [:new, :create]
    has_permission_on :message_library_documents, to: [:new, :create]
    has_permission_on :issue_message_threads, to: [:new, :create]
    has_permission_on :group_message_threads do
      to [:new, :create]
      if_attribute group: is_in { user.groups }
    end
    has_permission_on :message_threads, :group_message_threads, :issue_message_threads do
      to [:edit, :update]
      if_attribute group_committee_members: contains { user }
    end
    has_permission_on :message_threads, :group_message_threads, :issue_message_threads do
      to :show
      if_attribute private_to_committee?: is { true }, group_committee_members: contains { user }
    end
    has_permission_on :message_threads, :group_message_threads, :issue_message_threads do
      to :view
      if_attribute private_message?: is { true }, user: is { user }
      if_attribute private_message?: is { true }, created_by: is { user }
    end
    has_permission_on :message_threads, :group_message_threads, :issue_message_threads do
      to :show
      if_attribute private_to_group?: is { true }, group: is_in { user.groups }
    end
    has_permission_on :message_threads do
      to :open
      if_attribute subscribers: contains { user }, closed: is { true }
    end
    has_permission_on :message_threads do
      to :close
      if_attribute subscribers: contains { user }, latest_activity_at_to_i: lt { 48.hours.ago.to_i }, closed: is { false }
    end
    has_permission_on :messages do
      to [:approve, :reject]
      if_attribute thread: {group_committee_members: contains { user }}
    end

    has_permission_on :message_thread_subscriptions, to: :destroy
    has_permission_on :message_thread_subscriptions do
      to [:create]
      if_attribute public?: is { true }
    end
    has_permission_on :message_thread_subscriptions do
      to [:create]
      if_attribute private_to_group?: is { true }, group: is_in { user.groups }
    end
    has_permission_on :message_thread_subscriptions do
      to [:create]
      if_attribute private_to_committee?: is { true }, group_committee_members: contains { user }
    end
    has_permission_on :message_thread_tags, to: :update
    has_permission_on :message_thread_user_priorities, to: [:create, :update]
    has_permission_on [:message_thread_leaders], join_by: :and do
      to [:create]
      if_attribute subscribers: contains { user }, closed: is { false }
    end
    has_permission_on :message_photos, :message_links, :message_deadlines,
                      :message_library_items, :message_documents, :message_street_views,
                      :message_cyclestreets_photos, to: [:create, :view]
    has_permission_on :libraries, :library_documents, :library_notes, to: [:index, :new, :create, :show]
    has_permission_on :library_documents, :library_notes do
      to [:edit, :update]
      if_attribute created_by: is { user }
    end

    has_permission_on :library_tags, to: :update
    has_permission_on :planning_applications, to: [:view, :geometry, :all_geometries, :search, :show_uid, :hide, :unhide]
    has_permission_on :planning_application_issues, to: [:new, :create]
    has_permission_on :user_locations, to: [:manage, :geometry, :combined_geometry, :subscribe_to_threads]
    has_permission_on :user_prefs do
      to :manage
      if_attribute id: is { user.id }
    end
    has_permission_on :user_profiles do
      to :manage
      if_attribute id: is { user.id }
    end
    has_permission_on :user_profiles, to: :view
    has_permission_on :users do
      to :view_full_name
      if_attribute id: is { user.id }
      if_attribute groups: intersects_with { user.groups }
      if_attribute requested_groups: intersects_with { user.in_group_committee }
    end
    has_permission_on :users, to: :send_private_message, join_by: :and do
      if_permitted_to :view_full_name
      if_attribute id: is_not { user.id }
    end
    has_permission_on :users, to: :view_profile do
      if_permitted_to :view_full_name
      if_attribute profile: { visibility: 'public' }
    end
    has_permission_on :users_private_message_threads, to: [:new, :create] do
      if_permitted_to :send_private_message
    end
    has_permission_on :users_private_message_threads, to: [:index]
  end

  role :guest do
    has_permission_on :users do
      to :view_profile
      if_attribute profile: { visibility: 'public' }
    end
    has_permission_on :dashboards, to: [:search, :deadlines]
    has_permission_on :devise_sessions, :devise_registrations, :devise_confirmations,
                      :devise_invitations, :devise_passwords, :devise_invitable_registrations, :users_registrations, to: :manage
    has_permission_on :home, to: :show
    has_permission_on :groups, to: [:view, :all_geometries, :search]
    has_permission_on :group_profiles, to: [:view, :geometry]
    has_permission_on :issues, to: [:show, :index, :geometry, :all_geometries, :search]
    has_permission_on :issue_photos, to: [:show]
    has_permission_on :libraries, :library_documents, :library_notes, to: [:view, :search, :recent]
    has_permission_on :message_threads, :group_message_threads, :issue_message_threads do
      to :show
      if_attribute public?: is { true }
    end
    has_permission_on :message_threads, :group_message_threads, :issue_message_threads, to: [:index, :search]
    has_permission_on :message_photos, to: :show
    has_permission_on :pages, to: :show
    has_permission_on :api_v1_issues, to: :index
    has_permission_on :site_comments, to: [:new, :create]
    has_permission_on :tags, to: [:show, :autocomplete_tag_name, :index]
    has_permission_on :user_profiles, to: :view
  end
end

privileges do
  privilege :manage do
    includes :view, :new, :create, :edit, :update, :destroy
  end

  privilege :view do
    includes :index, :show
  end
end
