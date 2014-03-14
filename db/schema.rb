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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131206112436) do

  create_table "deadline_messages", :force => true do |t|
    t.integer  "thread_id",         :null => false
    t.integer  "message_id",        :null => false
    t.integer  "created_by_id",     :null => false
    t.datetime "deadline",          :null => false
    t.string   "title",             :null => false
    t.datetime "created_at"
    t.datetime "invalidated_at"
    t.integer  "invalidated_by_id"
  end

  create_table "document_messages", :force => true do |t|
    t.integer "thread_id",     :null => false
    t.integer "message_id",    :null => false
    t.integer "created_by_id", :null => false
    t.string  "title",         :null => false
    t.string  "file_uid"
    t.string  "file_name"
    t.integer "file_size"
  end

  create_table "group_membership_requests", :force => true do |t|
    t.integer  "user_id",        :null => false
    t.integer  "group_id",       :null => false
    t.string   "status",         :null => false
    t.integer  "actioned_by_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "message"
  end

  add_index "group_membership_requests", ["group_id"], :name => "index_group_membership_requests_on_group_id"
  add_index "group_membership_requests", ["user_id"], :name => "index_group_membership_requests_on_user_id"

  create_table "group_memberships", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "group_id",   :null => false
    t.string   "role",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.datetime "deleted_at"
  end

  add_index "group_memberships", ["group_id"], :name => "index_group_memberships_on_group_id"
  add_index "group_memberships", ["user_id"], :name => "index_group_memberships_on_user_id"

  create_table "group_prefs", :force => true do |t|
    t.integer  "group_id",                                     :null => false
    t.integer  "membership_secretary_id"
    t.boolean  "notify_membership_requests", :default => true, :null => false
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  add_index "group_prefs", ["group_id"], :name => "index_group_prefs_on_group_id", :unique => true

  create_table "group_profiles", :force => true do |t|
    t.integer  "group_id",                                                         :null => false
    t.text     "description"
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.spatial  "location",             :limit => {:srid=>4326, :type=>"geometry"}
    t.text     "joining_instructions"
  end

  add_index "group_profiles", ["group_id"], :name => "index_group_profiles_on_group_id"
  add_index "group_profiles", ["location"], :name => "index_group_profiles_on_location", :spatial => true

  create_table "groups", :force => true do |t|
    t.string   "name",                                         :null => false
    t.string   "short_name",                                   :null => false
    t.string   "website"
    t.string   "email"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.datetime "disabled_at"
    t.string   "default_thread_privacy", :default => "public", :null => false
  end

  add_index "groups", ["short_name"], :name => "index_groups_on_short_name"

  create_table "inbound_mails", :force => true do |t|
    t.string   "recipient",                        :null => false
    t.text     "raw_message",                      :null => false
    t.datetime "created_at",                       :null => false
    t.datetime "processed_at"
    t.boolean  "process_error", :default => false, :null => false
  end

  create_table "issue_tags", :id => false, :force => true do |t|
    t.integer "issue_id", :null => false
    t.integer "tag_id",   :null => false
  end

  add_index "issue_tags", ["issue_id", "tag_id"], :name => "index_issue_tags_on_issue_id_and_tag_id", :unique => true

  create_table "issues", :force => true do |t|
    t.integer  "created_by_id",                                             :null => false
    t.string   "title",                                                     :null => false
    t.text     "description",                                               :null => false
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
    t.datetime "deleted_at"
    t.spatial  "location",      :limit => {:srid=>4326, :type=>"geometry"}
    t.string   "photo_uid"
  end

  add_index "issues", ["created_by_id"], :name => "index_issues_on_created_by_id"
  add_index "issues", ["location"], :name => "index_issues_on_location", :spatial => true

  create_table "library_documents", :force => true do |t|
    t.integer "library_item_id", :null => false
    t.string  "title",           :null => false
    t.string  "file_uid"
    t.string  "file_name"
    t.integer "file_size"
  end

  create_table "library_item_messages", :force => true do |t|
    t.integer "thread_id",       :null => false
    t.integer "message_id",      :null => false
    t.integer "library_item_id", :null => false
    t.integer "created_by_id"
  end

  create_table "library_item_tags", :id => false, :force => true do |t|
    t.integer "library_item_id", :null => false
    t.integer "tag_id",          :null => false
  end

  add_index "library_item_tags", ["library_item_id", "tag_id"], :name => "index_library_item_tags_on_library_item_id_and_tag_id", :unique => true

  create_table "library_items", :force => true do |t|
    t.integer  "component_id"
    t.string   "component_type"
    t.integer  "created_by_id",                                              :null => false
    t.datetime "created_at",                                                 :null => false
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.spatial  "location",       :limit => {:srid=>4326, :type=>"geometry"}
  end

  add_index "library_items", ["location"], :name => "index_library_items_on_location", :spatial => true

  create_table "library_notes", :force => true do |t|
    t.integer "library_item_id",     :null => false
    t.string  "title"
    t.text    "body",                :null => false
    t.integer "library_document_id"
  end

  create_table "link_messages", :force => true do |t|
    t.integer  "thread_id",     :null => false
    t.integer  "message_id",    :null => false
    t.integer  "created_by_id", :null => false
    t.text     "url",           :null => false
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
  end

  create_table "location_categories", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "message_thread_tags", :id => false, :force => true do |t|
    t.integer "thread_id", :null => false
    t.integer "tag_id",    :null => false
  end

  add_index "message_thread_tags", ["thread_id", "tag_id"], :name => "index_message_thread_tags_on_thread_id_and_tag_id", :unique => true

  create_table "message_threads", :force => true do |t|
    t.integer  "issue_id"
    t.integer  "created_by_id", :null => false
    t.integer  "group_id"
    t.string   "title",         :null => false
    t.string   "privacy",       :null => false
    t.string   "state",         :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.datetime "deleted_at"
    t.string   "public_token"
  end

  add_index "message_threads", ["created_by_id"], :name => "index_message_threads_on_created_by_id"
  add_index "message_threads", ["group_id"], :name => "index_message_threads_on_group_id"
  add_index "message_threads", ["issue_id"], :name => "index_message_threads_on_issue_id"
  add_index "message_threads", ["public_token"], :name => "index_message_threads_on_public_token", :unique => true

  create_table "messages", :force => true do |t|
    t.integer  "created_by_id",  :null => false
    t.integer  "thread_id",      :null => false
    t.text     "body",           :null => false
    t.integer  "component_id"
    t.string   "component_type"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.datetime "deleted_at"
    t.datetime "censored_at"
  end

  add_index "messages", ["created_by_id"], :name => "index_messages_on_created_by_id"
  add_index "messages", ["thread_id"], :name => "index_messages_on_thread_id"

  create_table "photo_messages", :force => true do |t|
    t.integer  "thread_id",     :null => false
    t.integer  "message_id",    :null => false
    t.integer  "created_by_id", :null => false
    t.string   "photo_uid",     :null => false
    t.string   "caption"
    t.text     "description"
    t.datetime "created_at",    :null => false
  end

  create_table "site_comments", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "email"
    t.text     "body",         :null => false
    t.string   "context_url"
    t.text     "context_data"
    t.datetime "created_at",   :null => false
    t.datetime "viewed_at"
  end

  create_table "tags", :force => true do |t|
    t.string "name", :null => false
    t.string "icon"
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "thread_subscriptions", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "thread_id",  :null => false
    t.datetime "created_at", :null => false
    t.datetime "deleted_at"
  end

  add_index "thread_subscriptions", ["thread_id"], :name => "index_thread_subscriptions_on_thread_id"
  add_index "thread_subscriptions", ["thread_id"], :name => "sub_thread_id"
  add_index "thread_subscriptions", ["user_id"], :name => "index_thread_subscriptions_on_user_id"
  add_index "thread_subscriptions", ["user_id"], :name => "sub_user_id"

  create_table "thread_views", :force => true do |t|
    t.integer  "user_id",   :null => false
    t.integer  "thread_id", :null => false
    t.datetime "viewed_at", :null => false
  end

  add_index "thread_views", ["user_id", "thread_id"], :name => "index_thread_views_on_user_id_and_thread_id", :unique => true
  add_index "thread_views", ["user_id"], :name => "index_thread_views_on_user_id"

  create_table "user_locations", :force => true do |t|
    t.integer  "user_id",                                                 :null => false
    t.integer  "category_id",                                             :null => false
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.spatial  "location",    :limit => {:srid=>4326, :type=>"geometry"}
  end

  add_index "user_locations", ["location"], :name => "index_user_locations_on_location", :spatial => true
  add_index "user_locations", ["user_id"], :name => "index_user_locations_on_user_id"

  create_table "user_prefs", :force => true do |t|
    t.integer "user_id",                                          :null => false
    t.string  "involve_my_locations",    :default => "subscribe", :null => false
    t.string  "involve_my_groups",       :default => "notify",    :null => false
    t.boolean "involve_my_groups_admin", :default => false,       :null => false
    t.boolean "enable_email",            :default => false,       :null => false
  end

  add_index "user_prefs", ["enable_email"], :name => "index_user_prefs_on_enable_email"
  add_index "user_prefs", ["involve_my_groups"], :name => "index_user_prefs_on_involve_my_groups"
  add_index "user_prefs", ["involve_my_groups_admin"], :name => "index_user_prefs_on_involve_my_groups_admin"
  add_index "user_prefs", ["involve_my_locations"], :name => "index_user_prefs_on_involve_my_locations"
  add_index "user_prefs", ["user_id"], :name => "index_user_prefs_on_user_id", :unique => true

  create_table "user_profiles", :force => true do |t|
    t.integer "user_id",     :null => false
    t.string  "picture_uid"
    t.string  "website"
    t.text    "about"
  end

  add_index "user_profiles", ["user_id"], :name => "index_user_profiles_on_user_id"

  create_table "user_thread_priorities", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "thread_id",  :null => false
    t.integer  "priority",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "user_thread_priorities", ["thread_id"], :name => "index_user_thread_priorities_on_thread_id"
  add_index "user_thread_priorities", ["user_id"], :name => "index_user_thread_priorities_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "full_name",                                             :null => false
    t.string   "display_name"
    t.string   "role",                                                  :null => false
    t.string   "encrypted_password",     :limit => 128, :default => ""
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "disabled_at"
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
    t.string   "invitation_token",       :limit => 60
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "remembered_group_id"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.datetime "deleted_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["invitation_token"], :name => "index_users_on_invitation_token"

  create_table "votes", :force => true do |t|
    t.boolean  "vote",          :default => false
    t.integer  "voteable_id",                      :null => false
    t.string   "voteable_type",                    :null => false
    t.integer  "voter_id"
    t.string   "voter_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["voteable_id", "voteable_type"], :name => "index_votes_on_voteable_id_and_voteable_type"
  add_index "votes", ["voter_id", "voter_type", "voteable_id", "voteable_type"], :name => "fk_one_vote_per_user_per_entity", :unique => true
  add_index "votes", ["voter_id", "voter_type"], :name => "index_votes_on_voter_id_and_voter_type"

end
