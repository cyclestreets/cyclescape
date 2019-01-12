# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190112205550) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "action_messages", force: :cascade do |t|
    t.integer  "completing_message_id"
    t.string   "completing_message_type"
    t.integer  "thread_id",               null: false
    t.integer  "message_id",              null: false
    t.integer  "created_by_id",           null: false
    t.string   "description",             null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "action_messages", ["completing_message_id"], name: "index_action_messages_on_completing_message_id", using: :btree
  add_index "action_messages", ["created_by_id"], name: "index_action_messages_on_created_by_id", using: :btree
  add_index "action_messages", ["message_id"], name: "index_action_messages_on_message_id", using: :btree
  add_index "action_messages", ["thread_id"], name: "index_action_messages_on_thread_id", using: :btree

  create_table "constituencies", force: :cascade do |t|
    t.string   "name"
    t.geometry "location", limit: {:srid=>4326, :type=>"geometry"}, null: false
  end

  add_index "constituencies", ["location"], name: "index_constituencies_on_location", using: :gist

  create_table "cyclestreets_photo_messages", force: :cascade do |t|
    t.integer  "cyclestreets_id"
    t.json     "icon_properties"
    t.string   "photo_uid",                                                null: false
    t.integer  "thread_id",                                                null: false
    t.integer  "message_id",                                               null: false
    t.integer  "created_by_id",                                            null: false
    t.text     "caption"
    t.geometry "location",        limit: {:srid=>4326, :type=>"geometry"}, null: false
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.string   "photo_name"
  end

  add_index "cyclestreets_photo_messages", ["created_by_id"], name: "index_cyclestreets_photo_messages_on_created_by_id", using: :btree
  add_index "cyclestreets_photo_messages", ["message_id"], name: "index_cyclestreets_photo_messages_on_message_id", using: :btree
  add_index "cyclestreets_photo_messages", ["thread_id"], name: "index_cyclestreets_photo_messages_on_thread_id", using: :btree

  create_table "deadline_messages", force: :cascade do |t|
    t.integer  "thread_id",                                     null: false
    t.integer  "message_id",                                    null: false
    t.integer  "created_by_id",                                 null: false
    t.datetime "deadline",                                      null: false
    t.string   "title",             limit: 255,                 null: false
    t.datetime "created_at"
    t.datetime "invalidated_at"
    t.integer  "invalidated_by_id"
    t.boolean  "all_day",                       default: false, null: false
    t.datetime "updated_at"
  end

  add_index "deadline_messages", ["created_by_id"], name: "index_deadline_messages_on_created_by_id", using: :btree
  add_index "deadline_messages", ["message_id"], name: "index_deadline_messages_on_message_id", using: :btree
  add_index "deadline_messages", ["thread_id"], name: "index_deadline_messages_on_thread_id", using: :btree

  create_table "document_messages", force: :cascade do |t|
    t.integer  "thread_id",                 null: false
    t.integer  "message_id",                null: false
    t.integer  "created_by_id",             null: false
    t.string   "title",         limit: 255, null: false
    t.string   "file_uid",      limit: 255
    t.string   "file_name",     limit: 255
    t.integer  "file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "document_messages", ["created_by_id"], name: "index_document_messages_on_created_by_id", using: :btree
  add_index "document_messages", ["message_id"], name: "index_document_messages_on_message_id", using: :btree
  add_index "document_messages", ["thread_id"], name: "index_document_messages_on_thread_id", using: :btree

  create_table "group_membership_requests", force: :cascade do |t|
    t.integer  "user_id",                         null: false
    t.integer  "group_id",                        null: false
    t.string   "status",              limit: 255, null: false
    t.integer  "actioned_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "message"
    t.integer  "group_membership_id"
  end

  add_index "group_membership_requests", ["actioned_by_id"], name: "index_group_membership_requests_on_actioned_by_id", using: :btree
  add_index "group_membership_requests", ["group_id"], name: "index_group_membership_requests_on_group_id", using: :btree
  add_index "group_membership_requests", ["group_membership_id"], name: "index_group_membership_requests_on_group_membership_id", using: :btree
  add_index "group_membership_requests", ["user_id", "group_id"], name: "index_group_membership_requests_on_user_id_and_group_id", unique: true, using: :btree
  add_index "group_membership_requests", ["user_id"], name: "index_group_membership_requests_on_user_id", using: :btree

  create_table "group_memberships", force: :cascade do |t|
    t.integer  "user_id",                null: false
    t.integer  "group_id",               null: false
    t.string   "role",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.datetime "deleted_at"
  end

  add_index "group_memberships", ["group_id"], name: "index_group_memberships_on_group_id", using: :btree
  add_index "group_memberships", ["user_id", "group_id"], name: "index_group_memberships_on_user_id_and_group_id", unique: true, using: :btree
  add_index "group_memberships", ["user_id"], name: "index_group_memberships_on_user_id", using: :btree

  create_table "group_prefs", force: :cascade do |t|
    t.integer  "group_id",                                  null: false
    t.integer  "membership_secretary_id"
    t.boolean  "notify_membership_requests", default: true, null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "group_prefs", ["group_id"], name: "index_group_prefs_on_group_id", unique: true, using: :btree
  add_index "group_prefs", ["membership_secretary_id"], name: "index_group_prefs_on_membership_secretary_id", using: :btree

  create_table "group_profiles", force: :cascade do |t|
    t.integer  "group_id",                                                      null: false
    t.text     "description"
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
    t.geometry "location",             limit: {:srid=>4326, :type=>"geometry"}
    t.text     "joining_instructions"
    t.string   "picture_uid",          limit: 255
    t.string   "picture_name",         limit: 255
    t.text     "new_user_email",                                                null: false
    t.string   "logo_uid"
  end

  add_index "group_profiles", ["group_id"], name: "index_group_profiles_on_group_id", using: :btree
  add_index "group_profiles", ["location"], name: "index_group_profiles_on_location", using: :gist

  create_table "group_requests", force: :cascade do |t|
    t.string   "status",                 limit: 255
    t.integer  "user_id",                                               null: false
    t.integer  "actioned_by_id"
    t.string   "name",                   limit: 255,                    null: false
    t.string   "short_name",             limit: 255,                    null: false
    t.string   "default_thread_privacy", limit: 255, default: "public", null: false
    t.string   "website",                limit: 255
    t.string   "email",                  limit: 255,                    null: false
    t.text     "message"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.text     "rejection_message"
  end

  add_index "group_requests", ["actioned_by_id"], name: "index_group_requests_on_actioned_by_id", using: :btree
  add_index "group_requests", ["name"], name: "index_group_requests_on_name", unique: true, using: :btree
  add_index "group_requests", ["short_name"], name: "index_group_requests_on_short_name", unique: true, using: :btree
  add_index "group_requests", ["user_id"], name: "index_group_requests_on_user_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name",                   limit: 255,                    null: false
    t.string   "short_name",             limit: 255,                    null: false
    t.string   "website",                limit: 255
    t.string   "email",                  limit: 255
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.datetime "disabled_at"
    t.string   "default_thread_privacy", limit: 255, default: "public", null: false
    t.integer  "message_threads_count"
  end

  add_index "groups", ["short_name"], name: "index_groups_on_short_name", using: :btree

  create_table "hashtaggings", force: :cascade do |t|
    t.integer "hashtag_id"
    t.integer "message_id"
  end

  add_index "hashtaggings", ["hashtag_id", "message_id"], name: "index_hashtaggings_on_hashtag_id_and_message_id", using: :btree
  add_index "hashtaggings", ["hashtag_id"], name: "index_hashtaggings_on_hashtag_id", using: :btree
  add_index "hashtaggings", ["message_id"], name: "index_hashtaggings_on_message_id", using: :btree

  create_table "hashtags", force: :cascade do |t|
    t.string   "name"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "hashtags", ["group_id"], name: "index_hashtags_on_group_id", using: :btree
  add_index "hashtags", ["name", "group_id"], name: "index_hashtags_on_name_and_group_id", unique: true, using: :btree
  add_index "hashtags", ["name"], name: "index_hashtags_on_name", using: :btree

  create_table "hide_votes", force: :cascade do |t|
    t.integer  "planning_application_id"
    t.integer  "user_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "hide_votes", ["planning_application_id", "user_id"], name: "index_hide_votes_on_planning_application_id_and_user_id", unique: true, using: :btree

  create_table "html_issues", force: :cascade do |t|
    t.datetime "created_at", null: false
  end

  create_table "inbound_mails", force: :cascade do |t|
    t.string   "recipient",     limit: 255,                 null: false
    t.text     "raw_message",                               null: false
    t.datetime "created_at",                                null: false
    t.datetime "processed_at"
    t.boolean  "process_error",             default: false, null: false
  end

  create_table "issue_tags", id: false, force: :cascade do |t|
    t.integer "issue_id", null: false
    t.integer "tag_id",   null: false
  end

  add_index "issue_tags", ["issue_id", "tag_id"], name: "index_issue_tags_on_issue_id_and_tag_id", unique: true, using: :btree

  create_table "issues", force: :cascade do |t|
    t.integer  "created_by_id",                                                                    null: false
    t.string   "title",                   limit: 255,                                              null: false
    t.text     "description",                                                                      null: false
    t.datetime "created_at",                                                                       null: false
    t.datetime "updated_at",                                                                       null: false
    t.datetime "deleted_at"
    t.geometry "location",                limit: {:srid=>4326, :type=>"geometry"}
    t.string   "photo_uid",               limit: 255
    t.datetime "deadline"
    t.text     "external_url"
    t.boolean  "all_day",                                                          default: false, null: false
    t.integer  "planning_application_id"
    t.string   "photo_name"
  end

  add_index "issues", ["created_by_id"], name: "index_issues_on_created_by_id", using: :btree
  add_index "issues", ["location"], name: "index_issues_on_location", using: :gist
  add_index "issues", ["planning_application_id"], name: "index_issues_on_planning_application_id", using: :btree

  create_table "library_documents", force: :cascade do |t|
    t.integer  "library_item_id",             null: false
    t.string   "title",           limit: 255, null: false
    t.string   "file_uid",        limit: 255
    t.string   "file_name",       limit: 255
    t.integer  "file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "library_documents", ["library_item_id"], name: "index_library_documents_on_library_item_id", using: :btree

  create_table "library_item_messages", force: :cascade do |t|
    t.integer  "thread_id",       null: false
    t.integer  "message_id",      null: false
    t.integer  "library_item_id", null: false
    t.integer  "created_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "library_item_messages", ["created_by_id"], name: "index_library_item_messages_on_created_by_id", using: :btree
  add_index "library_item_messages", ["library_item_id", "thread_id"], name: "index_library_item_messages_on_library_item_id_and_thread_id", using: :btree
  add_index "library_item_messages", ["library_item_id"], name: "index_library_item_messages_on_library_item_id", using: :btree
  add_index "library_item_messages", ["message_id"], name: "index_library_item_messages_on_message_id", using: :btree
  add_index "library_item_messages", ["thread_id"], name: "index_library_item_messages_on_thread_id", using: :btree

  create_table "library_item_tags", id: false, force: :cascade do |t|
    t.integer "library_item_id", null: false
    t.integer "tag_id",          null: false
  end

  add_index "library_item_tags", ["library_item_id", "tag_id"], name: "index_library_item_tags_on_library_item_id_and_tag_id", unique: true, using: :btree

  create_table "library_items", force: :cascade do |t|
    t.integer  "component_id"
    t.string   "component_type", limit: 255
    t.integer  "created_by_id",                                           null: false
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.geometry "location",       limit: {:srid=>4326, :type=>"geometry"}
  end

  add_index "library_items", ["component_id", "component_type"], name: "index_library_items_on_component_id_and_component_type", using: :btree
  add_index "library_items", ["created_by_id"], name: "index_library_items_on_created_by_id", using: :btree
  add_index "library_items", ["location"], name: "index_library_items_on_location", using: :gist

  create_table "library_notes", force: :cascade do |t|
    t.integer  "library_item_id",                 null: false
    t.string   "title",               limit: 255
    t.text     "body",                            null: false
    t.integer  "library_document_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
  end

  add_index "library_notes", ["library_document_id"], name: "index_library_notes_on_library_document_id", using: :btree
  add_index "library_notes", ["library_item_id"], name: "index_library_notes_on_library_item_id", using: :btree

  create_table "link_messages", force: :cascade do |t|
    t.integer  "thread_id",                 null: false
    t.integer  "message_id",                null: false
    t.integer  "created_by_id",             null: false
    t.text     "url",                       null: false
    t.string   "title",         limit: 255
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "link_messages", ["created_by_id"], name: "index_link_messages_on_created_by_id", using: :btree
  add_index "link_messages", ["message_id"], name: "index_link_messages_on_message_id", using: :btree
  add_index "link_messages", ["thread_id"], name: "index_link_messages_on_thread_id", using: :btree

  create_table "location_categories", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "map_messages", force: :cascade do |t|
    t.geometry "location",      limit: {:srid=>4326, :type=>"geometry"}, null: false
    t.integer  "thread_id",                                              null: false
    t.integer  "message_id",                                             null: false
    t.integer  "created_by_id",                                          null: false
    t.text     "caption"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
  end

  add_index "map_messages", ["created_by_id"], name: "index_map_messages_on_created_by_id", using: :btree
  add_index "map_messages", ["message_id"], name: "index_map_messages_on_message_id", using: :btree
  add_index "map_messages", ["thread_id"], name: "index_map_messages_on_thread_id", using: :btree

  create_table "message_thread_closes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "message_thread_id"
    t.string   "event"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "message_thread_closes", ["message_thread_id"], name: "index_message_thread_closes_on_message_thread_id", using: :btree
  add_index "message_thread_closes", ["user_id"], name: "index_message_thread_closes_on_user_id", using: :btree

  create_table "message_thread_tags", id: false, force: :cascade do |t|
    t.integer "thread_id", null: false
    t.integer "tag_id",    null: false
  end

  add_index "message_thread_tags", ["thread_id", "tag_id"], name: "index_message_thread_tags_on_thread_id_and_tag_id", unique: true, using: :btree

  create_table "message_threads", force: :cascade do |t|
    t.integer  "issue_id"
    t.integer  "created_by_id",                             null: false
    t.integer  "group_id"
    t.string   "title",         limit: 255,                 null: false
    t.string   "privacy",       limit: 255,                 null: false
    t.string   "zzz_state",     limit: 255
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.datetime "deleted_at"
    t.string   "public_token",  limit: 255
    t.string   "status"
    t.boolean  "closed",                    default: false, null: false
    t.integer  "user_id"
  end

  add_index "message_threads", ["created_by_id"], name: "index_message_threads_on_created_by_id", using: :btree
  add_index "message_threads", ["group_id"], name: "index_message_threads_on_group_id", using: :btree
  add_index "message_threads", ["issue_id"], name: "index_message_threads_on_issue_id", using: :btree
  add_index "message_threads", ["public_token"], name: "index_message_threads_on_public_token", unique: true, using: :btree
  add_index "message_threads", ["user_id"], name: "index_message_threads_on_user_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "created_by_id",               null: false
    t.integer  "thread_id",                   null: false
    t.text     "body",                        null: false
    t.integer  "component_id"
    t.string   "component_type",  limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.datetime "deleted_at"
    t.datetime "censored_at"
    t.integer  "in_reply_to_id"
    t.string   "public_token",                null: false
    t.string   "status"
    t.string   "check_reason"
    t.integer  "inbound_mail_id"
  end

  add_index "messages", ["component_id", "component_type"], name: "index_messages_on_component_id_and_component_type", using: :btree
  add_index "messages", ["created_by_id"], name: "index_messages_on_created_by_id", using: :btree
  add_index "messages", ["in_reply_to_id"], name: "index_messages_on_in_reply_to_id", using: :btree
  add_index "messages", ["public_token"], name: "index_messages_on_public_token", unique: true, using: :btree
  add_index "messages", ["thread_id"], name: "index_messages_on_thread_id", using: :btree

  create_table "photo_messages", force: :cascade do |t|
    t.integer  "thread_id",                 null: false
    t.integer  "message_id",                null: false
    t.integer  "created_by_id",             null: false
    t.string   "photo_uid",     limit: 255, null: false
    t.string   "caption",       limit: 255
    t.text     "description"
    t.datetime "created_at",                null: false
    t.datetime "updated_at"
    t.string   "photo_name"
  end

  add_index "photo_messages", ["created_by_id"], name: "index_photo_messages_on_created_by_id", using: :btree
  add_index "photo_messages", ["message_id"], name: "index_photo_messages_on_message_id", using: :btree
  add_index "photo_messages", ["thread_id"], name: "index_photo_messages_on_thread_id", using: :btree

  create_table "planning_applications", force: :cascade do |t|
    t.text     "address"
    t.string   "postcode",                limit: 255
    t.text     "description"
    t.string   "openlylocal_council_url", limit: 255
    t.text     "url"
    t.string   "uid",                     limit: 255,                                             null: false
    t.integer  "zzz_issue_id"
    t.datetime "created_at",                                                                      null: false
    t.datetime "updated_at",                                                                      null: false
    t.geometry "location",                limit: {:srid=>4326, :type=>"geometry"}
    t.string   "authority_name",          limit: 255
    t.date     "start_date"
    t.integer  "hide_votes_count",                                                 default: 0
    t.boolean  "relevant",                                                         default: true, null: false
    t.string   "authority_param"
  end

  add_index "planning_applications", ["location"], name: "index_planning_applications_on_location", using: :gist
  add_index "planning_applications", ["uid", "authority_param"], name: "index_planning_applications_on_uid_and_authority_param", unique: true, using: :btree
  add_index "planning_applications", ["zzz_issue_id"], name: "index_planning_applications_on_zzz_issue_id", using: :btree

  create_table "planning_filters", force: :cascade do |t|
    t.string   "authority"
    t.string   "rule"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "potential_members", force: :cascade do |t|
    t.integer  "group_id"
    t.string   "email_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "potential_members", ["email_hash", "group_id"], name: "index_potential_members_on_email_hash_and_group_id", unique: true, using: :btree
  add_index "potential_members", ["group_id"], name: "index_potential_members_on_group_id", using: :btree

  create_table "site_comments", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name",         limit: 255
    t.string   "email",        limit: 255
    t.text     "body",                     null: false
    t.string   "context_url",  limit: 255
    t.text     "context_data"
    t.datetime "created_at",               null: false
    t.datetime "viewed_at"
    t.datetime "deleted_at"
  end

  add_index "site_comments", ["user_id"], name: "index_site_comments_on_user_id", using: :btree

  create_table "site_configs", force: :cascade do |t|
    t.string   "logo_uid"
    t.string   "application_name",                                                                                                                                  null: false
    t.string   "funder_image_footer1_uid"
    t.string   "funder_image_footer2_uid"
    t.string   "funder_image_footer3_uid"
    t.string   "funder_image_footer4_uid"
    t.string   "funder_image_footer5_uid"
    t.string   "funder_image_footer6_uid"
    t.string   "funder_name_footer1"
    t.string   "funder_name_footer2"
    t.string   "funder_name_footer3"
    t.string   "funder_name_footer4"
    t.string   "funder_name_footer5"
    t.string   "funder_name_footer6"
    t.string   "funder_url_footer1"
    t.string   "funder_url_footer2"
    t.string   "funder_url_footer3"
    t.string   "funder_url_footer4"
    t.string   "funder_url_footer5"
    t.string   "funder_url_footer6"
    t.geometry "nowhere_location",           limit: {:srid=>4326, :type=>"geometry"},                                                                               null: false
    t.string   "facebook_link"
    t.string   "twitter_link"
    t.string   "default_locale",                                                                                                                                    null: false
    t.string   "timezone",                                                                                                                                          null: false
    t.string   "ga_account_id"
    t.string   "ga_base_domain"
    t.string   "default_email",                                                                                                                                     null: false
    t.string   "email_domain",                                                                                                                                      null: false
    t.string   "geocoder_url",                                                                                                                                      null: false
    t.string   "geocoder_key"
    t.datetime "created_at",                                                                                                                                        null: false
    t.datetime "updated_at",                                                                                                                                        null: false
    t.string   "admin_email",                                                         default: "cyclescape-comments@cyclestreets.net",                              null: false
    t.string   "blog_url",                                                            default: "http://blog.cyclescape.org/",                                       null: false
    t.string   "blog_user_guide_url",                                                 default: "http://blog.cyclescape.org/guide/",                                 null: false
    t.string   "tile_server1_name",                                                   default: "OpenCycleMap",                                                      null: false
    t.string   "tile_server1_url",                                                    default: "https://{s}.tile.cyclestreets.net/opencyclemap/{z}/{x}/{y}@2x.png", null: false
    t.string   "tile_server2_name",                                                   default: "OS StreetView"
    t.string   "tile_server2_url",                                                    default: "https://{s}.tile.cyclestreets.net/osopendata/{z}/{x}/{y}.png"
    t.string   "tile_server3_name",                                                   default: "OpenStreetMap"
    t.string   "tile_server3_url",                                                    default: "https://{s}.tile.cyclestreets.net/mapnik/{z}/{x}/{y}.png"
    t.string   "blog_about_url",                                                      default: "http://blog.cyclescape.org/about/",                                 null: false
    t.string   "small_logo_uid"
    t.string   "tile_server1_type",                                                   default: "layers",                                                            null: false
    t.string   "tile_server2_type",                                                   default: "layers",                                                            null: false
    t.string   "tile_server3_type",                                                   default: "layers",                                                            null: false
    t.string   "tile_server1_options",                                                default: "{}",                                                                null: false
    t.string   "tile_server2_options",                                                default: "{}",                                                                null: false
    t.string   "tile_server3_options",                                                default: "{}",                                                                null: false
    t.string   "google_street_view_api_key"
  end

  create_table "street_view_messages", force: :cascade do |t|
    t.integer  "message_id"
    t.integer  "thread_id"
    t.integer  "created_by_id"
    t.decimal  "heading"
    t.decimal  "pitch"
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.geometry "location",      limit: {:srid=>4326, :type=>"geometry"}
    t.text     "caption"
  end

  add_index "street_view_messages", ["created_by_id"], name: "index_street_view_messages_on_created_by_id", using: :btree
  add_index "street_view_messages", ["location"], name: "index_street_view_messages_on_location", using: :gist
  add_index "street_view_messages", ["message_id"], name: "index_street_view_messages_on_message_id", using: :btree
  add_index "street_view_messages", ["thread_id"], name: "index_street_view_messages_on_thread_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "icon", limit: 255
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "thread_leader_messages", force: :cascade do |t|
    t.integer  "message_id"
    t.integer  "thread_id"
    t.integer  "unleading_id"
    t.integer  "created_by_id"
    t.boolean  "active",        default: true, null: false
    t.text     "description"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "thread_leader_messages", ["created_by_id"], name: "index_thread_leader_messages_on_created_by_id", using: :btree
  add_index "thread_leader_messages", ["message_id"], name: "index_thread_leader_messages_on_message_id", using: :btree
  add_index "thread_leader_messages", ["thread_id"], name: "index_thread_leader_messages_on_thread_id", using: :btree
  add_index "thread_leader_messages", ["unleading_id"], name: "index_thread_leader_messages_on_unleading_id", using: :btree

  create_table "thread_subscriptions", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "thread_id",  null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at"
  end

  add_index "thread_subscriptions", ["thread_id", "user_id"], name: "index_thread_subscriptions_on_thread_id_and_user_id", unique: true, where: "(deleted_at IS NULL)", using: :btree
  add_index "thread_subscriptions", ["thread_id"], name: "index_thread_subscriptions_on_thread_id", using: :btree
  add_index "thread_subscriptions", ["user_id"], name: "index_thread_subscriptions_on_user_id", using: :btree

  create_table "thread_views", force: :cascade do |t|
    t.integer  "user_id",   null: false
    t.integer  "thread_id", null: false
    t.datetime "viewed_at", null: false
  end

  add_index "thread_views", ["user_id", "thread_id"], name: "index_thread_views_on_user_id_and_thread_id", unique: true, using: :btree
  add_index "thread_views", ["user_id"], name: "index_thread_views_on_user_id", using: :btree

  create_table "user_blocks", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "blocked_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_blocks", ["blocked_id", "user_id"], name: "index_user_blocks_on_blocked_id_and_user_id", unique: true, using: :btree
  add_index "user_blocks", ["user_id"], name: "index_user_blocks_on_user_id", using: :btree

  create_table "user_locations", force: :cascade do |t|
    t.integer  "user_id",                                              null: false
    t.integer  "category_id"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.geometry "location",    limit: {:srid=>4326, :type=>"geometry"}
  end

  add_index "user_locations", ["category_id"], name: "index_user_locations_on_category_id", using: :btree
  add_index "user_locations", ["location"], name: "index_user_locations_on_location", using: :gist
  add_index "user_locations", ["user_id"], name: "index_user_locations_on_user_id", unique: true, using: :btree

  create_table "user_prefs", force: :cascade do |t|
    t.integer "user_id",                                                   null: false
    t.string  "involve_my_locations",    limit: 255, default: "subscribe", null: false
    t.string  "involve_my_groups",       limit: 255, default: "notify",    null: false
    t.boolean "involve_my_groups_admin",             default: false,       null: false
    t.boolean "zz_enable_email",                     default: false,       null: false
    t.string  "zz_profile_visibility",   limit: 255, default: "public",    null: false
    t.integer "email_status_id",                     default: 0,           null: false
  end

  add_index "user_prefs", ["email_status_id"], name: "index_user_prefs_on_email_status_id", using: :btree
  add_index "user_prefs", ["involve_my_groups"], name: "index_user_prefs_on_involve_my_groups", using: :btree
  add_index "user_prefs", ["involve_my_groups_admin"], name: "index_user_prefs_on_involve_my_groups_admin", using: :btree
  add_index "user_prefs", ["involve_my_locations"], name: "index_user_prefs_on_involve_my_locations", using: :btree
  add_index "user_prefs", ["user_id"], name: "index_user_prefs_on_user_id", unique: true, using: :btree
  add_index "user_prefs", ["zz_enable_email"], name: "index_user_prefs_on_zz_enable_email", using: :btree

  create_table "user_profiles", force: :cascade do |t|
    t.integer  "user_id",                                    null: false
    t.string   "picture_uid", limit: 255
    t.string   "website",     limit: 255
    t.text     "about"
    t.string   "visibility",  limit: 255, default: "public", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "locale"
  end

  add_index "user_profiles", ["user_id"], name: "index_user_profiles_on_user_id", using: :btree

  create_table "user_thread_priorities", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "thread_id",  null: false
    t.integer  "priority"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_thread_priorities", ["thread_id", "user_id"], name: "index_user_thread_priorities_on_thread_id_and_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "full_name",              limit: 255,                 null: false
    t.string   "display_name",           limit: 255
    t.string   "role",                   limit: 255,                 null: false
    t.string   "encrypted_password",     limit: 128, default: ""
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "disabled_at"
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "invitation_token",       limit: 255
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "remembered_group_id"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type",        limit: 255
    t.datetime "deleted_at"
    t.datetime "invitation_created_at"
    t.boolean  "approved",                           default: false, null: false
    t.datetime "last_seen_at"
    t.string   "public_token",                                       null: false
    t.string   "api_key"
  end

  add_index "users", ["api_key"], name: "index_users_on_api_key", unique: true, using: :btree
  add_index "users", ["display_name"], name: "index_users_on_display_name", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", using: :btree
  add_index "users", ["public_token"], name: "index_users_on_public_token", unique: true, using: :btree
  add_index "users", ["remembered_group_id"], name: "index_users_on_remembered_group_id", using: :btree

  create_table "votes", force: :cascade do |t|
    t.boolean  "vote",                      default: false
    t.integer  "voteable_id",                               null: false
    t.string   "voteable_type", limit: 255,                 null: false
    t.integer  "voter_id"
    t.string   "voter_type",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["voteable_id", "voteable_type"], name: "index_votes_on_voteable_id_and_voteable_type", using: :btree
  add_index "votes", ["voter_id", "voter_type", "voteable_id", "voteable_type"], name: "fk_one_vote_per_user_per_entity", unique: true, using: :btree
  add_index "votes", ["voter_id", "voter_type"], name: "index_votes_on_voter_id_and_voter_type", using: :btree

  create_table "wards", force: :cascade do |t|
    t.string   "name"
    t.geometry "location", limit: {:srid=>4326, :type=>"geometry"}, null: false
  end

  add_index "wards", ["location"], name: "index_wards_on_location", using: :gist

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
  add_foreign_key "potential_members", "groups"
  add_foreign_key "thread_leader_messages", "message_threads", column: "thread_id"
  add_foreign_key "thread_leader_messages", "messages"
  add_foreign_key "thread_leader_messages", "thread_leader_messages", column: "unleading_id"
  add_foreign_key "thread_leader_messages", "users", column: "created_by_id"
  add_foreign_key "user_blocks", "users"
  add_foreign_key "user_blocks", "users", column: "blocked_id"
end
