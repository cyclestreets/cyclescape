class InitSchema < ActiveRecord::Migration[5.2]
  def change
    enable_extension "pg_stat_statements"
    enable_extension "plpgsql"
    enable_extension "postgis"

    create_table "action_messages", id: :serial, force: :cascade do |t|
      t.integer "completing_message_id"
      t.string "completing_message_type"
      t.integer "thread_id", null: false
      t.integer "message_id", null: false
      t.integer "created_by_id", null: false
      t.string "description", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["completing_message_id"], name: "index_action_messages_on_completing_message_id"
      t.index ["created_by_id"], name: "index_action_messages_on_created_by_id"
      t.index ["message_id"], name: "index_action_messages_on_message_id"
      t.index ["thread_id"], name: "index_action_messages_on_thread_id"
    end

    create_table "constituencies", id: :serial, force: :cascade do |t|
      t.string "name"
      t.geometry "location", limit: {:srid=>4326, :type=>"geometry"}, null: false
      t.index ["location"], name: "index_constituencies_on_location", using: :gist
    end

    create_table "cyclestreets_photo_messages", id: :serial, force: :cascade do |t|
      t.integer "cyclestreets_id"
      t.json "icon_properties"
      t.string "photo_uid", null: false
      t.integer "thread_id", null: false
      t.integer "message_id", null: false
      t.integer "created_by_id", null: false
      t.text "caption"
      t.geometry "location", limit: {:srid=>4326, :type=>"geometry"}, null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "photo_name"
      t.integer "photo_preview_height"
      t.index ["created_by_id"], name: "index_cyclestreets_photo_messages_on_created_by_id"
      t.index ["message_id"], name: "index_cyclestreets_photo_messages_on_message_id"
      t.index ["thread_id"], name: "index_cyclestreets_photo_messages_on_thread_id"
    end

    create_table "deadline_messages", id: :serial, force: :cascade do |t|
      t.integer "thread_id", null: false
      t.integer "message_id", null: false
      t.integer "created_by_id", null: false
      t.datetime "deadline", null: false
      t.string "title", limit: 255, null: false
      t.datetime "created_at"
      t.datetime "invalidated_at"
      t.integer "invalidated_by_id"
      t.boolean "all_day", default: false, null: false
      t.datetime "updated_at"
      t.index ["created_by_id"], name: "index_deadline_messages_on_created_by_id"
      t.index ["message_id"], name: "index_deadline_messages_on_message_id"
      t.index ["thread_id"], name: "index_deadline_messages_on_thread_id"
    end

    create_table "document_messages", id: :serial, force: :cascade do |t|
      t.integer "thread_id", null: false
      t.integer "message_id", null: false
      t.integer "created_by_id", null: false
      t.string "title", limit: 255, null: false
      t.string "file_uid", limit: 255
      t.string "file_name", limit: 255
      t.integer "file_size"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["created_by_id"], name: "index_document_messages_on_created_by_id"
      t.index ["message_id"], name: "index_document_messages_on_message_id"
      t.index ["thread_id"], name: "index_document_messages_on_thread_id"
    end

    create_table "group_membership_requests", id: :serial, force: :cascade do |t|
      t.integer "user_id", null: false
      t.integer "group_id", null: false
      t.string "status", limit: 255, null: false
      t.integer "actioned_by_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text "message"
      t.integer "group_membership_id"
      t.text "rejection_message"
      t.index ["actioned_by_id"], name: "index_group_membership_requests_on_actioned_by_id"
      t.index ["group_id"], name: "index_group_membership_requests_on_group_id"
      t.index ["group_membership_id"], name: "index_group_membership_requests_on_group_membership_id"
      t.index ["user_id", "group_id"], name: "index_group_membership_requests_on_user_id_and_group_id", unique: true
      t.index ["user_id"], name: "index_group_membership_requests_on_user_id"
    end

    create_table "group_memberships", id: :serial, force: :cascade do |t|
      t.integer "user_id", null: false
      t.integer "group_id", null: false
      t.string "role", limit: 255, null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.datetime "deleted_at"
      t.index ["group_id"], name: "index_group_memberships_on_group_id"
      t.index ["user_id", "group_id"], name: "index_group_memberships_on_user_id_and_group_id", unique: true
      t.index ["user_id"], name: "index_group_memberships_on_user_id"
    end

    create_table "group_prefs", id: :serial, force: :cascade do |t|
      t.integer "group_id", null: false
      t.integer "membership_secretary_id"
      t.boolean "notify_membership_requests", default: true, null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["group_id"], name: "index_group_prefs_on_group_id", unique: true
      t.index ["membership_secretary_id"], name: "index_group_prefs_on_membership_secretary_id"
    end

    create_table "group_profiles", id: :serial, force: :cascade do |t|
      t.integer "group_id", null: false
      t.text "description"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.geometry "location", limit: {:srid=>4326, :type=>"geometry"}
      t.text "joining_instructions"
      t.string "picture_uid", limit: 255
      t.string "picture_name", limit: 255
      t.text "new_user_email", null: false
      t.string "logo_uid"
      t.index ["group_id"], name: "index_group_profiles_on_group_id"
      t.index ["location"], name: "index_group_profiles_on_location", using: :gist
    end

    create_table "group_requests", id: :serial, force: :cascade do |t|
      t.string "status", limit: 255
      t.integer "user_id", null: false
      t.integer "actioned_by_id"
      t.string "name", limit: 255, null: false
      t.string "short_name", limit: 255, null: false
      t.string "default_thread_privacy", limit: 255, default: "public", null: false
      t.string "website", limit: 255
      t.string "email", limit: 255, null: false
      t.text "message"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.text "rejection_message"
      t.index ["actioned_by_id"], name: "index_group_requests_on_actioned_by_id"
      t.index ["name"], name: "index_group_requests_on_name", unique: true
      t.index ["short_name"], name: "index_group_requests_on_short_name", unique: true
      t.index ["user_id"], name: "index_group_requests_on_user_id"
    end

    create_table "groups", id: :serial, force: :cascade do |t|
      t.string "name", limit: 255, null: false
      t.string "short_name", limit: 255, null: false
      t.string "website", limit: 255
      t.string "email", limit: 255
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.datetime "disabled_at"
      t.string "default_thread_privacy", limit: 255, default: "public", null: false
      t.integer "message_threads_count"
      t.index ["short_name"], name: "index_groups_on_short_name"
    end

    create_table "hashtaggings", id: :serial, force: :cascade do |t|
      t.integer "hashtag_id"
      t.integer "message_id"
      t.index ["hashtag_id", "message_id"], name: "index_hashtaggings_on_hashtag_id_and_message_id"
      t.index ["hashtag_id"], name: "index_hashtaggings_on_hashtag_id"
      t.index ["message_id"], name: "index_hashtaggings_on_message_id"
    end

    create_table "hashtags", id: :serial, force: :cascade do |t|
      t.string "name"
      t.integer "group_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["group_id"], name: "index_hashtags_on_group_id"
      t.index ["name", "group_id"], name: "index_hashtags_on_name_and_group_id", unique: true
      t.index ["name"], name: "index_hashtags_on_name"
    end

    create_table "hide_votes", id: :serial, force: :cascade do |t|
      t.integer "planning_application_id"
      t.integer "user_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["planning_application_id", "user_id"], name: "index_hide_votes_on_planning_application_id_and_user_id", unique: true
    end

    create_table "html_issues", id: :serial, force: :cascade do |t|
      t.datetime "created_at", null: false
    end

    create_table "inbound_mails", id: :serial, force: :cascade do |t|
      t.string "recipient", limit: 255, null: false
      t.text "raw_message", null: false
      t.datetime "created_at", null: false
      t.datetime "processed_at"
      t.boolean "process_error", default: false, null: false
    end

    create_table "issue_tags", id: false, force: :cascade do |t|
      t.integer "issue_id", null: false
      t.integer "tag_id", null: false
      t.index ["issue_id", "tag_id"], name: "index_issue_tags_on_issue_id_and_tag_id", unique: true
    end

    create_table "issues", id: :serial, force: :cascade do |t|
      t.integer "created_by_id", null: false
      t.string "title", limit: 255, null: false
      t.text "description", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.datetime "deleted_at"
      t.geometry "location", limit: {:srid=>4326, :type=>"geometry"}
      t.string "photo_uid", limit: 255
      t.datetime "deadline"
      t.text "external_url"
      t.boolean "all_day", default: false, null: false
      t.integer "planning_application_id"
      t.string "photo_name"
      t.index ["created_by_id"], name: "index_issues_on_created_by_id"
      t.index ["deleted_at"], name: "index_issues_on_deleted_at"
      t.index ["location"], name: "index_issues_on_location", using: :gist
      t.index ["planning_application_id"], name: "index_issues_on_planning_application_id"
    end

    create_table "library_documents", id: :serial, force: :cascade do |t|
      t.integer "library_item_id", null: false
      t.string "title", limit: 255, null: false
      t.string "file_uid", limit: 255
      t.string "file_name", limit: 255
      t.integer "file_size"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["library_item_id"], name: "index_library_documents_on_library_item_id"
    end

    create_table "library_item_messages", id: :serial, force: :cascade do |t|
      t.integer "thread_id", null: false
      t.integer "message_id", null: false
      t.integer "library_item_id", null: false
      t.integer "created_by_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["created_by_id"], name: "index_library_item_messages_on_created_by_id"
      t.index ["library_item_id", "thread_id"], name: "index_library_item_messages_on_library_item_id_and_thread_id"
      t.index ["library_item_id"], name: "index_library_item_messages_on_library_item_id"
      t.index ["message_id"], name: "index_library_item_messages_on_message_id"
      t.index ["thread_id"], name: "index_library_item_messages_on_thread_id"
    end

    create_table "library_item_tags", id: false, force: :cascade do |t|
      t.integer "library_item_id", null: false
      t.integer "tag_id", null: false
      t.index ["library_item_id", "tag_id"], name: "index_library_item_tags_on_library_item_id_and_tag_id", unique: true
    end

    create_table "library_items", id: :serial, force: :cascade do |t|
      t.integer "component_id"
      t.string "component_type", limit: 255
      t.integer "created_by_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at"
      t.datetime "deleted_at"
      t.geometry "location", limit: {:srid=>4326, :type=>"geometry"}
      t.index ["component_id", "component_type"], name: "index_library_items_on_component_id_and_component_type"
      t.index ["created_by_id"], name: "index_library_items_on_created_by_id"
      t.index ["location"], name: "index_library_items_on_location", using: :gist
    end

    create_table "library_notes", id: :serial, force: :cascade do |t|
      t.integer "library_item_id", null: false
      t.string "title", limit: 255
      t.text "body", null: false
      t.integer "library_document_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "url"
      t.index ["library_document_id"], name: "index_library_notes_on_library_document_id"
      t.index ["library_item_id"], name: "index_library_notes_on_library_item_id"
    end

    create_table "link_messages", id: :serial, force: :cascade do |t|
      t.integer "thread_id", null: false
      t.integer "message_id", null: false
      t.integer "created_by_id", null: false
      t.text "url", null: false
      t.string "title", limit: 255
      t.text "description"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["created_by_id"], name: "index_link_messages_on_created_by_id"
      t.index ["message_id"], name: "index_link_messages_on_message_id"
      t.index ["thread_id"], name: "index_link_messages_on_thread_id"
    end

    create_table "location_categories", id: :serial, force: :cascade do |t|
      t.string "name", limit: 255, null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "map_messages", id: :serial, force: :cascade do |t|
      t.geometry "location", limit: {:srid=>4326, :type=>"geometry"}, null: false
      t.integer "thread_id", null: false
      t.integer "message_id", null: false
      t.integer "created_by_id", null: false
      t.text "caption"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["created_by_id"], name: "index_map_messages_on_created_by_id"
      t.index ["message_id"], name: "index_map_messages_on_message_id"
      t.index ["thread_id"], name: "index_map_messages_on_thread_id"
    end

    create_table "message_thread_closes", id: :serial, force: :cascade do |t|
      t.integer "user_id"
      t.integer "message_thread_id"
      t.string "event"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["message_thread_id"], name: "index_message_thread_closes_on_message_thread_id"
      t.index ["user_id"], name: "index_message_thread_closes_on_user_id"
    end

    create_table "message_thread_tags", id: false, force: :cascade do |t|
      t.integer "thread_id", null: false
      t.integer "tag_id", null: false
      t.index ["thread_id", "tag_id"], name: "index_message_thread_tags_on_thread_id_and_tag_id", unique: true
    end

    create_table "message_threads", id: :serial, force: :cascade do |t|
      t.integer "issue_id"
      t.integer "created_by_id", null: false
      t.integer "group_id"
      t.string "title", limit: 255, null: false
      t.string "privacy", limit: 255, null: false
      t.string "zzz_state", limit: 255
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.datetime "deleted_at"
      t.string "public_token", limit: 255
      t.string "status"
      t.boolean "closed", default: false, null: false
      t.integer "user_id"
      t.index ["created_by_id"], name: "index_message_threads_on_created_by_id"
      t.index ["group_id"], name: "index_message_threads_on_group_id"
      t.index ["issue_id"], name: "index_message_threads_on_issue_id"
      t.index ["public_token"], name: "index_message_threads_on_public_token", unique: true
      t.index ["user_id"], name: "index_message_threads_on_user_id"
    end

    create_table "messages", id: :serial, force: :cascade do |t|
      t.integer "created_by_id", null: false
      t.integer "thread_id", null: false
      t.text "body", default: "", null: false
      t.integer "component_id"
      t.string "component_type", limit: 255
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.datetime "deleted_at"
      t.datetime "censored_at"
      t.integer "in_reply_to_id"
      t.string "public_token", null: false
      t.string "status"
      t.string "check_reason"
      t.integer "inbound_mail_id"
      t.index ["component_id", "component_type"], name: "index_messages_on_component_id_and_component_type"
      t.index ["created_by_id"], name: "index_messages_on_created_by_id"
      t.index ["in_reply_to_id"], name: "index_messages_on_in_reply_to_id"
      t.index ["public_token"], name: "index_messages_on_public_token", unique: true
      t.index ["thread_id"], name: "index_messages_on_thread_id"
    end

    create_table "pghero_query_stats", force: :cascade do |t|
      t.text "database"
      t.text "user"
      t.text "query"
      t.bigint "query_hash"
      t.float "total_time"
      t.bigint "calls"
      t.datetime "captured_at"
      t.index ["database", "captured_at"], name: "index_pghero_query_stats_on_database_and_captured_at"
    end

    create_table "photo_messages", id: :serial, force: :cascade do |t|
      t.integer "thread_id", null: false
      t.integer "message_id", null: false
      t.integer "created_by_id", null: false
      t.string "photo_uid", limit: 255, null: false
      t.string "caption", limit: 255
      t.text "description"
      t.datetime "created_at", null: false
      t.datetime "updated_at"
      t.string "photo_name"
      t.integer "photo_preview_height"
      t.index ["created_by_id"], name: "index_photo_messages_on_created_by_id"
      t.index ["message_id"], name: "index_photo_messages_on_message_id"
      t.index ["thread_id"], name: "index_photo_messages_on_thread_id"
    end

    create_table "planning_applications", id: :serial, force: :cascade do |t|
      t.text "address"
      t.string "postcode", limit: 255
      t.text "description"
      t.text "url"
      t.string "uid", limit: 255, null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.geometry "location", limit: {:srid=>4326, :type=>"geometry"}
      t.string "authority_name", limit: 255
      t.date "start_date"
      t.integer "hide_votes_count", default: 0
      t.boolean "relevant", default: true, null: false
      t.string "authority_param"
      t.string "app_size"
      t.string "app_state"
      t.string "app_type"
      t.datetime "when_updated"
      t.string "associated_id"
      t.index ["associated_id"], name: "index_planning_applications_on_associated_id"
      t.index ["location"], name: "index_planning_applications_on_location", using: :gist
      t.index ["uid", "authority_param"], name: "index_planning_applications_on_uid_and_authority_param", unique: true
    end

    create_table "planning_filters", id: :serial, force: :cascade do |t|
      t.string "authority"
      t.string "rule"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end

    create_table "poll_messages", force: :cascade do |t|
      t.bigint "thread_id", null: false
      t.bigint "message_id", null: false
      t.bigint "created_by_id", null: false
      t.text "question", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["created_by_id"], name: "index_poll_messages_on_created_by_id"
      t.index ["message_id"], name: "index_poll_messages_on_message_id"
      t.index ["thread_id"], name: "index_poll_messages_on_thread_id"
    end

    create_table "poll_options", force: :cascade do |t|
      t.bigint "poll_message_id", null: false
      t.text "option", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["poll_message_id"], name: "index_poll_options_on_poll_message_id"
    end

    create_table "poll_votes", force: :cascade do |t|
      t.bigint "user_id", null: false
      t.bigint "poll_option_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["poll_option_id"], name: "index_poll_votes_on_poll_option_id"
      t.index ["user_id", "poll_option_id"], name: "index_poll_votes_on_user_id_and_poll_option_id", unique: true
      t.index ["user_id"], name: "index_poll_votes_on_user_id"
    end

    create_table "potential_members", id: :serial, force: :cascade do |t|
      t.integer "group_id"
      t.string "email_hash"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["email_hash", "group_id"], name: "index_potential_members_on_email_hash_and_group_id", unique: true
      t.index ["group_id"], name: "index_potential_members_on_group_id"
    end

    create_table "site_comments", id: :serial, force: :cascade do |t|
      t.integer "user_id"
      t.string "name", limit: 255
      t.string "email", limit: 255
      t.text "body", null: false
      t.string "context_url", limit: 255
      t.text "context_data"
      t.datetime "created_at", null: false
      t.datetime "viewed_at"
      t.datetime "deleted_at"
      t.datetime "sent_to_cyclestreets_at"
      t.jsonb "cyclestreets_response"
      t.index ["user_id"], name: "index_site_comments_on_user_id"
    end

    create_table "site_configs", id: :serial, force: :cascade do |t|
      t.string "logo_uid"
      t.string "application_name", null: false
      t.string "funder_image_footer1_uid"
      t.string "funder_image_footer2_uid"
      t.string "funder_image_footer3_uid"
      t.string "funder_image_footer4_uid"
      t.string "funder_image_footer5_uid"
      t.string "funder_image_footer6_uid"
      t.string "funder_name_footer1"
      t.string "funder_name_footer2"
      t.string "funder_name_footer3"
      t.string "funder_name_footer4"
      t.string "funder_name_footer5"
      t.string "funder_name_footer6"
      t.string "funder_url_footer1"
      t.string "funder_url_footer2"
      t.string "funder_url_footer3"
      t.string "funder_url_footer4"
      t.string "funder_url_footer5"
      t.string "funder_url_footer6"
      t.geometry "nowhere_location", limit: {:srid=>4326, :type=>"geometry"}, null: false
      t.string "facebook_link"
      t.string "twitter_link"
      t.string "default_locale", null: false
      t.string "timezone", null: false
      t.string "ga_account_id"
      t.string "ga_base_domain"
      t.string "default_email", null: false
      t.string "email_domain", null: false
      t.string "geocoder_url", null: false
      t.string "geocoder_key"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "admin_email", default: "cyclescape-comments@cyclestreets.net", null: false
      t.string "blog_url", default: "http://blog.cyclescape.org/", null: false
      t.string "blog_user_guide_url", default: "http://blog.cyclescape.org/guide/", null: false
      t.string "tile_server1_name", default: "OpenCycleMap", null: false
      t.string "tile_server1_url", default: "https://{s}.tile.cyclestreets.net/opencyclemap/{z}/{x}/{y}@2x.png", null: false
      t.string "tile_server2_name", default: "OS StreetView"
      t.string "tile_server2_url", default: "https://{s}.tile.cyclestreets.net/osopendata/{z}/{x}/{y}.png"
      t.string "tile_server3_name", default: "OpenStreetMap"
      t.string "tile_server3_url", default: "https://{s}.tile.cyclestreets.net/mapnik/{z}/{x}/{y}.png"
      t.string "blog_about_url", default: "http://blog.cyclescape.org/about/", null: false
      t.string "small_logo_uid"
      t.string "tile_server1_type", default: "layers", null: false
      t.string "tile_server2_type", default: "layers", null: false
      t.string "tile_server3_type", default: "layers", null: false
      t.string "tile_server1_options", default: "{}", null: false
      t.string "tile_server2_options", default: "{}", null: false
      t.string "tile_server3_options", default: "{}", null: false
      t.string "google_street_view_api_key"
      t.string "planit_api_key"
    end

    create_table "street_view_messages", id: :serial, force: :cascade do |t|
      t.integer "message_id"
      t.integer "thread_id"
      t.integer "created_by_id"
      t.decimal "heading"
      t.decimal "pitch"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.geometry "location", limit: {:srid=>4326, :type=>"geometry"}
      t.text "caption"
      t.index ["created_by_id"], name: "index_street_view_messages_on_created_by_id"
      t.index ["location"], name: "index_street_view_messages_on_location", using: :gist
      t.index ["message_id"], name: "index_street_view_messages_on_message_id"
      t.index ["thread_id"], name: "index_street_view_messages_on_thread_id"
    end

    create_table "tags", id: :serial, force: :cascade do |t|
      t.string "name", limit: 255, null: false
      t.string "icon", limit: 255
      t.index ["name"], name: "index_tags_on_name", unique: true
    end

    create_table "thread_leader_messages", id: :serial, force: :cascade do |t|
      t.integer "message_id"
      t.integer "thread_id"
      t.integer "unleading_id"
      t.integer "created_by_id"
      t.boolean "active", default: true, null: false
      t.text "description"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["created_by_id"], name: "index_thread_leader_messages_on_created_by_id"
      t.index ["message_id"], name: "index_thread_leader_messages_on_message_id"
      t.index ["thread_id"], name: "index_thread_leader_messages_on_thread_id"
      t.index ["unleading_id"], name: "index_thread_leader_messages_on_unleading_id"
    end

    create_table "thread_subscriptions", id: :serial, force: :cascade do |t|
      t.integer "user_id", null: false
      t.integer "thread_id", null: false
      t.datetime "created_at", null: false
      t.datetime "deleted_at"
      t.index ["thread_id", "user_id"], name: "index_thread_subscriptions_on_thread_id_and_user_id", unique: true, where: "(deleted_at IS NULL)"
      t.index ["thread_id"], name: "index_thread_subscriptions_on_thread_id"
      t.index ["user_id"], name: "index_thread_subscriptions_on_user_id"
    end

    create_table "thread_views", id: :serial, force: :cascade do |t|
      t.integer "user_id", null: false
      t.integer "thread_id", null: false
      t.datetime "viewed_at", null: false
      t.index ["user_id", "thread_id"], name: "index_thread_views_on_user_id_and_thread_id", unique: true
      t.index ["user_id"], name: "index_thread_views_on_user_id"
    end

    create_table "user_blocks", id: :serial, force: :cascade do |t|
      t.integer "user_id", null: false
      t.integer "blocked_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["blocked_id", "user_id"], name: "index_user_blocks_on_blocked_id_and_user_id", unique: true
      t.index ["user_id"], name: "index_user_blocks_on_user_id"
    end

    create_table "user_locations", id: :serial, force: :cascade do |t|
      t.integer "user_id", null: false
      t.integer "category_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.geometry "location", limit: {:srid=>4326, :type=>"geometry"}
      t.index ["category_id"], name: "index_user_locations_on_category_id"
      t.index ["location"], name: "index_user_locations_on_location", using: :gist
      t.index ["user_id"], name: "index_user_locations_on_user_id", unique: true
    end

    create_table "user_prefs", id: :serial, force: :cascade do |t|
      t.integer "user_id", null: false
      t.string "involve_my_locations", limit: 255, default: "subscribe", null: false
      t.string "involve_my_groups", limit: 255, default: "notify", null: false
      t.boolean "involve_my_groups_admin", default: false, null: false
      t.boolean "zz_enable_email", default: false, null: false
      t.string "zz_profile_visibility", limit: 255, default: "public", null: false
      t.integer "email_status_id", default: 0, null: false
      t.index ["email_status_id"], name: "index_user_prefs_on_email_status_id"
      t.index ["involve_my_groups"], name: "index_user_prefs_on_involve_my_groups"
      t.index ["involve_my_groups_admin"], name: "index_user_prefs_on_involve_my_groups_admin"
      t.index ["involve_my_locations"], name: "index_user_prefs_on_involve_my_locations"
      t.index ["user_id"], name: "index_user_prefs_on_user_id", unique: true
      t.index ["zz_enable_email"], name: "index_user_prefs_on_zz_enable_email"
    end

    create_table "user_profiles", id: :serial, force: :cascade do |t|
      t.integer "user_id", null: false
      t.string "picture_uid", limit: 255
      t.string "website", limit: 255
      t.text "about"
      t.string "visibility", limit: 255, default: "public", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer "locale"
      t.index ["user_id"], name: "index_user_profiles_on_user_id"
    end

    create_table "user_thread_favourites", force: :cascade do |t|
      t.bigint "user_id", null: false
      t.bigint "thread_id", null: false
      t.datetime "created_at", null: false
      t.index ["thread_id", "user_id"], name: "index_user_thread_favourites_on_thread_id_and_user_id", unique: true
      t.index ["user_id"], name: "index_user_thread_favourites_on_user_id"
    end

    create_table "user_thread_priorities", id: :serial, force: :cascade do |t|
      t.integer "user_id", null: false
      t.integer "thread_id", null: false
      t.integer "priority"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["thread_id", "user_id"], name: "index_user_thread_priorities_on_thread_id_and_user_id"
    end

    create_table "users", id: :serial, force: :cascade do |t|
      t.string "email", limit: 255, default: "", null: false
      t.string "full_name", limit: 255, null: false
      t.string "display_name", limit: 255
      t.string "role", limit: 255, null: false
      t.string "encrypted_password", limit: 128, default: ""
      t.string "confirmation_token", limit: 255
      t.datetime "confirmed_at"
      t.datetime "confirmation_sent_at"
      t.string "reset_password_token", limit: 255
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.datetime "disabled_at"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "invitation_token", limit: 255
      t.datetime "invitation_sent_at"
      t.datetime "invitation_accepted_at"
      t.integer "remembered_group_id"
      t.integer "invitation_limit"
      t.integer "invited_by_id"
      t.string "invited_by_type", limit: 255
      t.datetime "deleted_at"
      t.datetime "invitation_created_at"
      t.boolean "approved", default: false, null: false
      t.datetime "last_seen_at"
      t.string "public_token", null: false
      t.string "api_key"
      t.string "provider"
      t.string "uid"
      t.index ["api_key"], name: "index_users_on_api_key", unique: true
      t.index ["display_name"], name: "index_users_on_display_name", unique: true
      t.index ["email"], name: "index_users_on_email", unique: true
      t.index ["invitation_token"], name: "index_users_on_invitation_token"
      t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
      t.index ["public_token"], name: "index_users_on_public_token", unique: true
      t.index ["remembered_group_id"], name: "index_users_on_remembered_group_id"
    end

    create_table "votes", id: :serial, force: :cascade do |t|
      t.boolean "vote", default: false
      t.integer "voteable_id", null: false
      t.string "voteable_type", limit: 255, null: false
      t.integer "voter_id"
      t.string "voter_type", limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["voteable_id", "voteable_type"], name: "index_votes_on_voteable_id_and_voteable_type"
      t.index ["voter_id", "voter_type", "voteable_id", "voteable_type"], name: "fk_one_vote_per_user_per_entity", unique: true
      t.index ["voter_id", "voter_type"], name: "index_votes_on_voter_id_and_voter_type"
    end

    create_table "wards", id: :serial, force: :cascade do |t|
      t.string "name"
      t.geometry "location", limit: {:srid=>4326, :type=>"geometry"}, null: false
      t.index ["location"], name: "index_wards_on_location", using: :gist
    end

    add_foreign_key "action_messages", "message_threads", column: "thread_id"
    add_foreign_key "action_messages", "messages"
    add_foreign_key "action_messages", "users", column: "created_by_id"
    add_foreign_key "cyclestreets_photo_messages", "message_threads", column: "thread_id"
    add_foreign_key "cyclestreets_photo_messages", "messages"
    add_foreign_key "cyclestreets_photo_messages", "users", column: "created_by_id"
    add_foreign_key "group_membership_requests", "group_memberships"
    add_foreign_key "hashtaggings", "hashtags"
    add_foreign_key "hashtaggings", "messages"
    add_foreign_key "hashtags", "groups"
    add_foreign_key "issues", "planning_applications"
    add_foreign_key "map_messages", "message_threads", column: "thread_id"
    add_foreign_key "map_messages", "messages"
    add_foreign_key "map_messages", "users", column: "created_by_id"
    add_foreign_key "message_thread_closes", "message_threads"
    add_foreign_key "message_thread_closes", "users"
    add_foreign_key "message_threads", "users"
    add_foreign_key "messages", "inbound_mails"
    add_foreign_key "poll_messages", "message_threads", column: "thread_id"
    add_foreign_key "poll_messages", "messages"
    add_foreign_key "poll_messages", "users", column: "created_by_id"
    add_foreign_key "poll_options", "poll_messages"
    add_foreign_key "poll_votes", "poll_options"
    add_foreign_key "poll_votes", "users"
    add_foreign_key "potential_members", "groups"
    add_foreign_key "thread_leader_messages", "message_threads", column: "thread_id"
    add_foreign_key "thread_leader_messages", "messages"
    add_foreign_key "thread_leader_messages", "thread_leader_messages", column: "unleading_id"
    add_foreign_key "thread_leader_messages", "users", column: "created_by_id"
    add_foreign_key "user_blocks", "users"
    add_foreign_key "user_blocks", "users", column: "blocked_id"
    add_foreign_key "user_thread_favourites", "message_threads", column: "thread_id"
    add_foreign_key "user_thread_favourites", "users"
  end
end
