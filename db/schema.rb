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

ActiveRecord::Schema.define(:version => 20110926153130) do

  create_table "group_memberships", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "group_id",   :null => false
    t.string   "role",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.datetime "deleted_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "name",        :null => false
    t.string   "short_name",  :null => false
    t.string   "website"
    t.string   "email"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.datetime "disabled_at"
  end

  create_table "issue_categories", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "issues", :force => true do |t|
    t.integer  "created_by_id",                                             :null => false
    t.string   "title",                                                     :null => false
    t.text     "description",                                               :null => false
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
    t.datetime "deleted_at"
    t.integer  "category_id"
    t.spatial  "location",      :limit => {:srid=>4326, :type=>"geometry"}
  end

  create_table "message_threads", :force => true do |t|
    t.integer  "issue_id"
    t.integer  "created_by_id", :null => false
    t.integer  "group_id"
    t.string   "title",         :null => false
    t.text     "description",   :null => false
    t.string   "privacy",       :null => false
    t.string   "state",         :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "messages", :force => true do |t|
    t.integer  "created_by_id",  :null => false
    t.integer  "thread_id",      :null => false
    t.text     "body",           :null => false
    t.integer  "component_id"
    t.string   "component_type"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.datetime "deleted_at"
  end

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
  end

  add_index "users", ["invitation_token"], :name => "index_users_on_invitation_token"

end
