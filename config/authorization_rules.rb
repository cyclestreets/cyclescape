# frozen_string_literal: true

authorization do
  role :root do
    has_omnipotence
  end

  role :admin do
    includes :member
    has_permission_on :group_members, :group_memberships, :group_membership_requests, :group_profiles, :group_prefs, to: :manage
    has_permission_on :admin_groups, to: %i[manage disable enable]
    has_permission_on :group_requests do
      to %i[index review confirm reject destroy]
    end
    has_permission_on :admin_users, to: %i[manage approve]
    has_permission_on :admin_user_locations, to: %i[manage geometry combined_geometry]
    has_permission_on :admin_home, to: :view
    has_permission_on :admin_message_moderations, to: :view
    has_permission_on :admin_stats, to: :view
    has_permission_on :admin_planning_filters, to: :manage
    has_permission_on :admin_site_configs, to: :manage
    has_permission_on :admin_templates, to: :show
    has_permission_on :issues, to: %i[edit update destroy]
    has_permission_on :"library/documents", :library_documents, :library_notes, to: :manage
    has_permission_on :message_threads, :group_message_threads, :issue_message_threads, to: %i[manage edit_all_fields]
    has_permission_on :messages, to: %i[censor approve reject]
    has_permission_on :site_comments, to: :manage
    has_permission_on :user_prefs, :user_profiles, to: :manage
    has_permission_on :users, to: %i[view_profile view_full_name]
    has_permission_on :rails_mailers, to: %i[view index preview]
  end

  role :member do
    includes :guest
    has_permission_on :dashboards, to: [:show]
    has_permission_on :group_requests do
      to %i[new create]
    end
    has_permission_on :group_requests do
      to :cancel
      if_attribute user: is { user }
    end
    has_permission_on :groups do
      to :view_active_users
      if_attribute committee_members: contains { user }
    end
    has_permission_on :group_members, :group_memberships do
      to :manage
      if_attribute committee_members: contains { user }
    end
    has_permission_on :group_potential_members do
      to %i[new create]
      if_attribute committee_members: contains { user }
    end
    has_permission_on :group_membership_requests do
      to %i[new create]
    end
    has_permission_on :group_membership_requests do
      to :cancel
      if_attribute user: is { user }
    end
    has_permission_on :group_membership_requests do
      to %i[index review confirm reject]
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

    has_permission_on :issues, to: %i[new create vote_up vote_clear]
    has_permission_on :issues do
      to %i[edit update]
      if_attribute created_by: is { user }
    end
    has_permission_on :issue_tags, to: [:update]
    has_permission_on :messages, to: %i[new]
    has_permission_on :messages, to: %i[create vote_up vote_clear] do
      if_permitted_to :show, :thread
    end
    has_permission_on :message_library_notes, to: %i[new create]
    has_permission_on :message_library_documents, to: %i[new create]
    has_permission_on :issue_message_threads, to: %i[new create]
    has_permission_on :group_message_threads do
      to %i[new create]
      if_attribute group: is_in { user.groups }
    end
    has_permission_on :message_threads, :group_message_threads, :issue_message_threads do
      to %i[manage edit_all_fields]
      if_attribute group_committee_members: contains { user }
    end
    has_permission_on :message_threads, :group_message_threads, :issue_message_threads do
      to %i[edit update]
      if_attribute created_by: is { user }, created_at_as_i: is_in { 24.hours.ago.to_i..Time.now.to_i }
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
      if_attribute subscribers: contains { user }, closed: is { false }
    end
    has_permission_on :message_threads do
      to :vote_detail
      if_permitted_to :show
    end

    has_permission_on :messages do
      to %i[censor approve reject]
      if_attribute thread: { group_committee_members: contains { user } }
    end

    has_permission_on :message_thread_subscriptions, to: %i[destroy edit] do
      if_attribute user: is { user }
    end
    has_permission_on :message_thread_subscriptions do
      to [:create]
      if_attribute thread: { public?: true }
    end
    has_permission_on :message_thread_subscriptions do
      to [:create]
      if_attribute thread: { private_to_group?: true, group: is_in { user.groups } }
    end
    has_permission_on :message_thread_subscriptions do
      to [:create]
      if_attribute thread: { private_to_committee?: true, group_committee_members: contains { user } }
    end
    has_permission_on :message_thread_tags, to: :update
    has_permission_on :message_thread_user_priorities, to: %i[create update]
    has_permission_on [:message_thread_leaders], join_by: :and do
      to [:create]
      if_attribute subscribers: contains { user }, closed: false
    end
    has_permission_on(
      :message_cyclestreets_photos, :message_documents,
      :message_library_items, :message_photos
    ) do
      to %i[create view]
      if_permitted_to :show, :thread
    end
    has_permission_on :message_polls, to: :vote do
      if_permitted_to :show, :thread
    end
    has_permission_on :libraries, :library_documents, :library_notes, to: %i[index new create show]
    has_permission_on :"library/documents", :library_documents, :library_notes do
      to :manage
      if_attribute created_by: is { user }
    end

    has_permission_on :library_tags, to: :update
    has_permission_on :planning_applications, to: %i[view geometry all_geometries search show_uid hide unhide]
    has_permission_on :planning_application_issues, to: %i[new create]
    has_permission_on :user_locations, to: %i[manage geometry combined_geometry]
    has_permission_on :user_prefs do
      to :manage
      if_attribute id: is { user.id }
    end
    has_permission_on :user_profiles do
      to :manage
      if_attribute id: is { user.id }
    end
    has_permission_on :user_profiles, to: :view do
      if_permitted_to :view_profile
    end
    has_permission_on :users do
      to :view_full_name
      if_attribute id: is { user.id }
      if_attribute groups: intersects_with { user.groups }
      if_attribute requested_groups: intersects_with { user.in_group_committee }
    end
    has_permission_on :users, to: :send_private_message, join_by: :and do
      if_permitted_to :view_full_name
      if_attribute id: is_not { user.id }
      if_attribute blocked_user_ids: does_not_contain { user.id }
      if_attribute blocked_by_user_ids: does_not_contain { user.id }
    end
    has_permission_on :users, to: :view_profile do
      if_permitted_to :view_full_name
      if_attribute profile: { visibility: "public" }
    end
    has_permission_on :users_private_message_threads, to: %i[new create] do
      if_permitted_to :view_full_name
      if_attribute id: is_not { user.id }
    end
    has_permission_on :users_private_message_threads, to: [:index]
    has_permission_on :private_messages, to: [:index]
    has_permission_on :user_blocks, to: [:manage]
  end

  role :guest do
    has_permission_on :users do
      to :view_profile
      if_attribute profile: { visibility: "public" }
    end
    has_permission_on :dashboards, to: %i[search deadlines]
    has_permission_on :devise_sessions, :devise_registrations, :devise_confirmations,
                      :devise_invitations, :devise_passwords, :devise_invitable_registrations, :users_registrations, to: :manage
    has_permission_on :home, to: :show
    has_permission_on :groups, to: %i[view all_geometries search]
    has_permission_on :group_profiles, to: %i[view geometry]
    has_permission_on :issues, to: %i[show index geometry all_geometries search vote_detail]

    has_permission_on :issue_photos, to: [:show]
    has_permission_on :libraries, :library_documents, :library_notes, to: %i[view search relevant]
    has_permission_on :message_threads, :group_message_threads, :issue_message_threads do
      to :show
      if_attribute public?: is { true }
    end
    has_permission_on :message_threads, :group_message_threads, :issue_message_threads, to: %i[index search]
    has_permission_on :message_photos do
      to :show
      if_permitted_to :show, :thread
    end

    has_permission_on :pages, to: :show
    has_permission_on :api_v1_issues, to: :index
    has_permission_on :site_comments, to: %i[new create]
    has_permission_on :tags, to: %i[show autocomplete_tag_name index]
    has_permission_on :user_profiles, to: :view do
      if_permitted_to :view_profile
    end
    has_permission_on :group_hashtags do
      to %i[index show]
    end
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
