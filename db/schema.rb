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

ActiveRecord::Schema.define(:version => 20150515193920) do

  create_table "addr", :primary_key => "gid", :force => true do |t|
    t.integer "tlid",      :limit => 8
    t.string  "fromhn",    :limit => 12
    t.string  "tohn",      :limit => 12
    t.string  "side",      :limit => 1
    t.string  "zip",       :limit => 5
    t.string  "plus4",     :limit => 4
    t.string  "fromtyp",   :limit => 1
    t.string  "totyp",     :limit => 1
    t.integer "fromarmid"
    t.integer "toarmid"
    t.string  "arid",      :limit => 22
    t.string  "mtfcc",     :limit => 5
    t.string  "statefp",   :limit => 2
  end

  create_table "addrfeat", :primary_key => "gid", :force => true do |t|
    t.integer "tlid",       :limit => 8
    t.string  "statefp",    :limit => 2,                                   :null => false
    t.string  "aridl",      :limit => 22
    t.string  "aridr",      :limit => 22
    t.string  "linearid",   :limit => 22
    t.string  "fullname",   :limit => 100
    t.string  "lfromhn",    :limit => 12
    t.string  "ltohn",      :limit => 12
    t.string  "rfromhn",    :limit => 12
    t.string  "rtohn",      :limit => 12
    t.string  "zipl",       :limit => 5
    t.string  "zipr",       :limit => 5
    t.string  "edge_mtfcc", :limit => 5
    t.string  "parityl",    :limit => 1
    t.string  "parityr",    :limit => 1
    t.string  "plus4l",     :limit => 4
    t.string  "plus4r",     :limit => 4
    t.string  "lfromtyp",   :limit => 1
    t.string  "ltotyp",     :limit => 1
    t.string  "rfromtyp",   :limit => 1
    t.string  "rtotyp",     :limit => 1
    t.string  "offsetl",    :limit => 1
    t.string  "offsetr",    :limit => 1
    t.spatial "the_geom",   :limit => {:srid=>4269, :type=>"line_string"}
  end

  create_table "bg", :id => false, :force => true do |t|
    t.integer "gid",                                                       :null => false
    t.string  "statefp",  :limit => 2
    t.string  "countyfp", :limit => 3
    t.string  "tractce",  :limit => 6
    t.string  "blkgrpce", :limit => 1
    t.string  "bg_id",    :limit => 12,                                    :null => false
    t.string  "namelsad", :limit => 13
    t.string  "mtfcc",    :limit => 5
    t.string  "funcstat", :limit => 1
    t.float   "aland"
    t.float   "awater"
    t.string  "intptlat", :limit => 11
    t.string  "intptlon", :limit => 12
    t.spatial "the_geom", :limit => {:srid=>4269, :type=>"multi_polygon"}
  end

  create_table "county", :id => false, :force => true do |t|
    t.integer "gid",                                                       :null => false
    t.string  "statefp",  :limit => 2
    t.string  "countyfp", :limit => 3
    t.string  "countyns", :limit => 8
    t.string  "cntyidfp", :limit => 5,                                     :null => false
    t.string  "name",     :limit => 100
    t.string  "namelsad", :limit => 100
    t.string  "lsad",     :limit => 2
    t.string  "classfp",  :limit => 2
    t.string  "mtfcc",    :limit => 5
    t.string  "csafp",    :limit => 3
    t.string  "cbsafp",   :limit => 5
    t.string  "metdivfp", :limit => 5
    t.string  "funcstat", :limit => 1
    t.integer "aland",    :limit => 8
    t.float   "awater"
    t.string  "intptlat", :limit => 11
    t.string  "intptlon", :limit => 12
    t.spatial "the_geom", :limit => {:srid=>4269, :type=>"multi_polygon"}
  end

  create_table "county_lookup", :id => false, :force => true do |t|
    t.integer "st_code",               :null => false
    t.string  "state",   :limit => 2
    t.integer "co_code",               :null => false
    t.string  "name",    :limit => 90
  end

  create_table "countysub_lookup", :id => false, :force => true do |t|
    t.integer "st_code",               :null => false
    t.string  "state",   :limit => 2
    t.integer "co_code",               :null => false
    t.string  "county",  :limit => 90
    t.integer "cs_code",               :null => false
    t.string  "name",    :limit => 90
  end

  create_table "cousub", :id => false, :force => true do |t|
    t.integer "gid",                                                                                      :null => false
    t.string  "statefp",  :limit => 2
    t.string  "countyfp", :limit => 3
    t.string  "cousubfp", :limit => 5
    t.string  "cousubns", :limit => 8
    t.string  "cosbidfp", :limit => 10,                                                                   :null => false
    t.string  "name",     :limit => 100
    t.string  "namelsad", :limit => 100
    t.string  "lsad",     :limit => 2
    t.string  "classfp",  :limit => 2
    t.string  "mtfcc",    :limit => 5
    t.string  "cnectafp", :limit => 3
    t.string  "nectafp",  :limit => 5
    t.string  "nctadvfp", :limit => 5
    t.string  "funcstat", :limit => 1
    t.decimal "aland",                                                     :precision => 14, :scale => 0
    t.decimal "awater",                                                    :precision => 14, :scale => 0
    t.string  "intptlat", :limit => 11
    t.string  "intptlon", :limit => 12
    t.spatial "the_geom", :limit => {:srid=>4269, :type=>"multi_polygon"}
  end

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

  create_table "direction_lookup", :id => false, :force => true do |t|
    t.string "name",   :limit => 20, :null => false
    t.string "abbrev", :limit => 3
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

  create_table "edges", :primary_key => "gid", :force => true do |t|
    t.string  "statefp",    :limit => 2
    t.string  "countyfp",   :limit => 3
    t.integer "tlid",       :limit => 8
    t.decimal "tfidl",                                                           :precision => 10, :scale => 0
    t.decimal "tfidr",                                                           :precision => 10, :scale => 0
    t.string  "mtfcc",      :limit => 5
    t.string  "fullname",   :limit => 100
    t.string  "smid",       :limit => 22
    t.string  "lfromadd",   :limit => 12
    t.string  "ltoadd",     :limit => 12
    t.string  "rfromadd",   :limit => 12
    t.string  "rtoadd",     :limit => 12
    t.string  "zipl",       :limit => 5
    t.string  "zipr",       :limit => 5
    t.string  "featcat",    :limit => 1
    t.string  "hydroflg",   :limit => 1
    t.string  "railflg",    :limit => 1
    t.string  "roadflg",    :limit => 1
    t.string  "olfflg",     :limit => 1
    t.string  "passflg",    :limit => 1
    t.string  "divroad",    :limit => 1
    t.string  "exttyp",     :limit => 1
    t.string  "ttyp",       :limit => 1
    t.string  "deckedroad", :limit => 1
    t.string  "artpath",    :limit => 1
    t.string  "persist",    :limit => 1
    t.string  "gcseflg",    :limit => 1
    t.string  "offsetl",    :limit => 1
    t.string  "offsetr",    :limit => 1
    t.decimal "tnidf",                                                           :precision => 10, :scale => 0
    t.decimal "tnidt",                                                           :precision => 10, :scale => 0
    t.spatial "the_geom",   :limit => {:srid=>4269, :type=>"multi_line_string"}
  end

  create_table "faces", :primary_key => "gid", :force => true do |t|
    t.decimal "tfid",                                                        :precision => 10, :scale => 0
    t.string  "statefp00",  :limit => 2
    t.string  "countyfp00", :limit => 3
    t.string  "tractce00",  :limit => 6
    t.string  "blkgrpce00", :limit => 1
    t.string  "blockce00",  :limit => 4
    t.string  "cousubfp00", :limit => 5
    t.string  "submcdfp00", :limit => 5
    t.string  "conctyfp00", :limit => 5
    t.string  "placefp00",  :limit => 5
    t.string  "aiannhfp00", :limit => 5
    t.string  "aiannhce00", :limit => 4
    t.string  "comptyp00",  :limit => 1
    t.string  "trsubfp00",  :limit => 5
    t.string  "trsubce00",  :limit => 3
    t.string  "anrcfp00",   :limit => 5
    t.string  "elsdlea00",  :limit => 5
    t.string  "scsdlea00",  :limit => 5
    t.string  "unsdlea00",  :limit => 5
    t.string  "uace00",     :limit => 5
    t.string  "cd108fp",    :limit => 2
    t.string  "sldust00",   :limit => 3
    t.string  "sldlst00",   :limit => 3
    t.string  "vtdst00",    :limit => 6
    t.string  "zcta5ce00",  :limit => 5
    t.string  "tazce00",    :limit => 6
    t.string  "ugace00",    :limit => 5
    t.string  "puma5ce00",  :limit => 5
    t.string  "statefp",    :limit => 2
    t.string  "countyfp",   :limit => 3
    t.string  "tractce",    :limit => 6
    t.string  "blkgrpce",   :limit => 1
    t.string  "blockce",    :limit => 4
    t.string  "cousubfp",   :limit => 5
    t.string  "submcdfp",   :limit => 5
    t.string  "conctyfp",   :limit => 5
    t.string  "placefp",    :limit => 5
    t.string  "aiannhfp",   :limit => 5
    t.string  "aiannhce",   :limit => 4
    t.string  "comptyp",    :limit => 1
    t.string  "trsubfp",    :limit => 5
    t.string  "trsubce",    :limit => 3
    t.string  "anrcfp",     :limit => 5
    t.string  "ttractce",   :limit => 6
    t.string  "tblkgpce",   :limit => 1
    t.string  "elsdlea",    :limit => 5
    t.string  "scsdlea",    :limit => 5
    t.string  "unsdlea",    :limit => 5
    t.string  "uace",       :limit => 5
    t.string  "cd111fp",    :limit => 2
    t.string  "sldust",     :limit => 3
    t.string  "sldlst",     :limit => 3
    t.string  "vtdst",      :limit => 6
    t.string  "zcta5ce",    :limit => 5
    t.string  "tazce",      :limit => 6
    t.string  "ugace",      :limit => 5
    t.string  "puma5ce",    :limit => 5
    t.string  "csafp",      :limit => 3
    t.string  "cbsafp",     :limit => 5
    t.string  "metdivfp",   :limit => 5
    t.string  "cnectafp",   :limit => 3
    t.string  "nectafp",    :limit => 5
    t.string  "nctadvfp",   :limit => 5
    t.string  "lwflag",     :limit => 1
    t.string  "offset",     :limit => 1
    t.float   "atotal"
    t.string  "intptlat",   :limit => 11
    t.string  "intptlon",   :limit => 12
    t.spatial "the_geom",   :limit => {:srid=>4269, :type=>"multi_polygon"}
  end

  create_table "featnames", :primary_key => "gid", :force => true do |t|
    t.integer "tlid",       :limit => 8
    t.string  "fullname",   :limit => 100
    t.string  "name",       :limit => 100
    t.string  "predirabrv", :limit => 15
    t.string  "pretypabrv", :limit => 50
    t.string  "prequalabr", :limit => 15
    t.string  "sufdirabrv", :limit => 15
    t.string  "suftypabrv", :limit => 50
    t.string  "sufqualabr", :limit => 15
    t.string  "predir",     :limit => 2
    t.string  "pretyp",     :limit => 3
    t.string  "prequal",    :limit => 2
    t.string  "sufdir",     :limit => 2
    t.string  "suftyp",     :limit => 3
    t.string  "sufqual",    :limit => 2
    t.string  "linearid",   :limit => 22
    t.string  "mtfcc",      :limit => 5
    t.string  "paflag",     :limit => 1
    t.string  "statefp",    :limit => 2
  end

  create_table "geocode_settings", :id => false, :force => true do |t|
    t.text "name",       :null => false
    t.text "setting"
    t.text "unit"
    t.text "category"
    t.text "short_desc"
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

  create_table "group_memberships", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "group_id",   :null => false
    t.string   "role",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.datetime "deleted_at"
  end

  create_table "group_prefs", :force => true do |t|
    t.integer  "group_id",                                     :null => false
    t.integer  "membership_secretary_id"
    t.boolean  "notify_membership_requests", :default => true, :null => false
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  create_table "group_profiles", :force => true do |t|
    t.integer  "group_id",                                                         :null => false
    t.text     "description"
    t.datetime "created_at",                                                       :null => false
    t.datetime "updated_at",                                                       :null => false
    t.spatial  "location",             :limit => {:srid=>4326, :type=>"geometry"}
    t.text     "joining_instructions"
  end

  create_table "group_requests", :force => true do |t|
    t.string   "status"
    t.integer  "user_id",                                      :null => false
    t.integer  "actioned_by_id"
    t.string   "name",                                         :null => false
    t.string   "short_name",                                   :null => false
    t.string   "default_thread_privacy", :default => "public", :null => false
    t.string   "website"
    t.string   "email",                                        :null => false
    t.text     "message"
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
    t.text     "rejection_message"
  end

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

  create_table "hide_votes", :force => true do |t|
    t.integer  "planning_application_id"
    t.integer  "user_id"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

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

  create_table "library_items", :force => true do |t|
    t.integer  "component_id"
    t.string   "component_type"
    t.integer  "created_by_id",                                              :null => false
    t.datetime "created_at",                                                 :null => false
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.spatial  "location",       :limit => {:srid=>4326, :type=>"geometry"}
  end

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

  create_table "loader_lookuptables", :id => false, :force => true do |t|
    t.integer "process_order",                        :default => 1000,  :null => false
    t.text    "lookup_name",                                             :null => false
    t.text    "table_name"
    t.boolean "single_mode",                          :default => true,  :null => false
    t.boolean "load",                                 :default => true,  :null => false
    t.boolean "level_county",                         :default => false, :null => false
    t.boolean "level_state",                          :default => false, :null => false
    t.boolean "level_nation",                         :default => false, :null => false
    t.text    "post_load_process"
    t.boolean "single_geom_mode",                     :default => false
    t.string  "insert_mode",           :limit => 1,   :default => "c",   :null => false
    t.text    "pre_load_process"
    t.string  "columns_exclude",       :limit => nil
    t.text    "website_root_override"
  end

  create_table "loader_platform", :id => false, :force => true do |t|
    t.string "os",                     :limit => 50, :null => false
    t.text   "declare_sect"
    t.text   "pgbin"
    t.text   "wget"
    t.text   "unzip_command"
    t.text   "psql"
    t.text   "path_sep"
    t.text   "loader"
    t.text   "environ_set_command"
    t.text   "county_process_command"
  end

  create_table "loader_variables", :id => false, :force => true do |t|
    t.string "tiger_year",     :limit => 4, :null => false
    t.text   "website_root"
    t.text   "staging_fold"
    t.text   "data_schema"
    t.text   "staging_schema"
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

  create_table "pagc_gaz", :force => true do |t|
    t.integer "seq"
    t.text    "word"
    t.text    "stdword"
    t.integer "token"
    t.boolean "is_custom", :default => true, :null => false
  end

  create_table "pagc_lex", :force => true do |t|
    t.integer "seq"
    t.text    "word"
    t.text    "stdword"
    t.integer "token"
    t.boolean "is_custom", :default => true, :null => false
  end

  create_table "pagc_rules", :force => true do |t|
    t.text    "rule"
    t.boolean "is_custom", :default => true
  end

  create_table "photo_messages", :force => true do |t|
    t.integer  "thread_id",     :null => false
    t.integer  "message_id",    :null => false
    t.integer  "created_by_id", :null => false
    t.string   "photo_uid",     :null => false
    t.string   "caption"
    t.text     "description"
    t.datetime "created_at",    :null => false
  end

  create_table "place", :id => false, :force => true do |t|
    t.integer "gid",                                                       :null => false
    t.string  "statefp",  :limit => 2
    t.string  "placefp",  :limit => 5
    t.string  "placens",  :limit => 8
    t.string  "plcidfp",  :limit => 7,                                     :null => false
    t.string  "name",     :limit => 100
    t.string  "namelsad", :limit => 100
    t.string  "lsad",     :limit => 2
    t.string  "classfp",  :limit => 2
    t.string  "cpi",      :limit => 1
    t.string  "pcicbsa",  :limit => 1
    t.string  "pcinecta", :limit => 1
    t.string  "mtfcc",    :limit => 5
    t.string  "funcstat", :limit => 1
    t.integer "aland",    :limit => 8
    t.integer "awater",   :limit => 8
    t.string  "intptlat", :limit => 11
    t.string  "intptlon", :limit => 12
    t.spatial "the_geom", :limit => {:srid=>4269, :type=>"multi_polygon"}
  end

  create_table "place_lookup", :id => false, :force => true do |t|
    t.integer "st_code",               :null => false
    t.string  "state",   :limit => 2
    t.integer "pl_code",               :null => false
    t.string  "name",    :limit => 90
  end

  create_table "planning_applications", :force => true do |t|
    t.text     "address"
    t.string   "postcode"
    t.text     "description"
    t.string   "openlylocal_council_url"
    t.text     "url"
    t.string   "uid",                                                                                :null => false
    t.integer  "issue_id"
    t.datetime "created_at",                                                                         :null => false
    t.datetime "updated_at",                                                                         :null => false
    t.spatial  "location",                :limit => {:srid=>4326, :type=>"geometry"}
    t.string   "authority_name"
    t.date     "start_date"
    t.integer  "hide_votes_count",                                                    :default => 0
  end

  create_table "secondary_unit_lookup", :id => false, :force => true do |t|
    t.string "name",   :limit => 20, :null => false
    t.string "abbrev", :limit => 5
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
    t.datetime "deleted_at"
  end

  create_table "state", :id => false, :force => true do |t|
    t.integer "gid",                                                       :null => false
    t.string  "region",   :limit => 2
    t.string  "division", :limit => 2
    t.string  "statefp",  :limit => 2,                                     :null => false
    t.string  "statens",  :limit => 8
    t.string  "stusps",   :limit => 2,                                     :null => false
    t.string  "name",     :limit => 100
    t.string  "lsad",     :limit => 2
    t.string  "mtfcc",    :limit => 5
    t.string  "funcstat", :limit => 1
    t.integer "aland",    :limit => 8
    t.integer "awater",   :limit => 8
    t.string  "intptlat", :limit => 11
    t.string  "intptlon", :limit => 12
    t.spatial "the_geom", :limit => {:srid=>4269, :type=>"multi_polygon"}
  end

  create_table "state_lookup", :id => false, :force => true do |t|
    t.integer "st_code",               :null => false
    t.string  "name",    :limit => 40
    t.string  "abbrev",  :limit => 3
    t.string  "statefp", :limit => 2
  end

  create_table "street_type_lookup", :id => false, :force => true do |t|
    t.string  "name",   :limit => 50,                    :null => false
    t.string  "abbrev", :limit => 50
    t.boolean "is_hw",                :default => false, :null => false
  end

  create_table "street_view_messages", :force => true do |t|
    t.integer  "message_id"
    t.integer  "thread_id"
    t.integer  "created_by_id"
    t.decimal  "heading"
    t.decimal  "pitch"
    t.datetime "created_at",                                                :null => false
    t.datetime "updated_at",                                                :null => false
    t.spatial  "location",      :limit => {:srid=>4326, :type=>"geometry"}
    t.text     "caption"
  end

  create_table "tabblock", :id => false, :force => true do |t|
    t.integer "gid",                                                          :null => false
    t.string  "statefp",     :limit => 2
    t.string  "countyfp",    :limit => 3
    t.string  "tractce",     :limit => 6
    t.string  "blockce",     :limit => 4
    t.string  "tabblock_id", :limit => 16,                                    :null => false
    t.string  "name",        :limit => 20
    t.string  "mtfcc",       :limit => 5
    t.string  "ur",          :limit => 1
    t.string  "uace",        :limit => 5
    t.string  "funcstat",    :limit => 1
    t.float   "aland"
    t.float   "awater"
    t.string  "intptlat",    :limit => 11
    t.string  "intptlon",    :limit => 12
    t.spatial "the_geom",    :limit => {:srid=>4269, :type=>"multi_polygon"}
  end

  create_table "tags", :force => true do |t|
    t.string "name", :null => false
    t.string "icon"
  end

  create_table "thread_subscriptions", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "thread_id",  :null => false
    t.datetime "created_at", :null => false
    t.datetime "deleted_at"
  end

  create_table "thread_views", :force => true do |t|
    t.integer  "user_id",   :null => false
    t.integer  "thread_id", :null => false
    t.datetime "viewed_at", :null => false
  end

  create_table "tract", :id => false, :force => true do |t|
    t.integer "gid",                                                       :null => false
    t.string  "statefp",  :limit => 2
    t.string  "countyfp", :limit => 3
    t.string  "tractce",  :limit => 6
    t.string  "tract_id", :limit => 11,                                    :null => false
    t.string  "name",     :limit => 7
    t.string  "namelsad", :limit => 20
    t.string  "mtfcc",    :limit => 5
    t.string  "funcstat", :limit => 1
    t.float   "aland"
    t.float   "awater"
    t.string  "intptlat", :limit => 11
    t.string  "intptlon", :limit => 12
    t.spatial "the_geom", :limit => {:srid=>4269, :type=>"multi_polygon"}
  end

  create_table "user_locations", :force => true do |t|
    t.integer  "user_id",                                                 :null => false
    t.integer  "category_id",                                             :null => false
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.spatial  "location",    :limit => {:srid=>4326, :type=>"geometry"}
  end

  create_table "user_prefs", :force => true do |t|
    t.integer "user_id",                                          :null => false
    t.string  "involve_my_locations",    :default => "subscribe", :null => false
    t.string  "involve_my_groups",       :default => "notify",    :null => false
    t.boolean "involve_my_groups_admin", :default => false,       :null => false
    t.boolean "enable_email",            :default => false,       :null => false
    t.string  "zz_profile_visibility",   :default => "public",    :null => false
  end

  create_table "user_profiles", :force => true do |t|
    t.integer "user_id",                           :null => false
    t.string  "picture_uid"
    t.string  "website"
    t.text    "about"
    t.string  "visibility",  :default => "public", :null => false
  end

  create_table "user_thread_priorities", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "thread_id",  :null => false
    t.integer  "priority",   :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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
    t.integer  "remembered_group_id"
    t.integer  "invitation_limit"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
    t.datetime "deleted_at"
  end

  create_table "votes", :force => true do |t|
    t.boolean  "vote",          :default => false
    t.integer  "voteable_id",                      :null => false
    t.string   "voteable_type",                    :null => false
    t.integer  "voter_id"
    t.string   "voter_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "zcta5", :id => false, :force => true do |t|
    t.integer "gid",                                                       :null => false
    t.string  "statefp",  :limit => 2,                                     :null => false
    t.string  "zcta5ce",  :limit => 5,                                     :null => false
    t.string  "classfp",  :limit => 2
    t.string  "mtfcc",    :limit => 5
    t.string  "funcstat", :limit => 1
    t.float   "aland"
    t.float   "awater"
    t.string  "intptlat", :limit => 11
    t.string  "intptlon", :limit => 12
    t.string  "partflg",  :limit => 1
    t.spatial "the_geom", :limit => {:srid=>4269, :type=>"multi_polygon"}
  end

  create_table "zip_lookup", :id => false, :force => true do |t|
    t.integer "zip",                   :null => false
    t.integer "st_code"
    t.string  "state",   :limit => 2
    t.integer "co_code"
    t.string  "county",  :limit => 90
    t.integer "cs_code"
    t.string  "cousub",  :limit => 90
    t.integer "pl_code"
    t.string  "place",   :limit => 90
    t.integer "cnt"
  end

  create_table "zip_lookup_all", :id => false, :force => true do |t|
    t.integer "zip"
    t.integer "st_code"
    t.string  "state",   :limit => 2
    t.integer "co_code"
    t.string  "county",  :limit => 90
    t.integer "cs_code"
    t.string  "cousub",  :limit => 90
    t.integer "pl_code"
    t.string  "place",   :limit => 90
    t.integer "cnt"
  end

  create_table "zip_lookup_base", :id => false, :force => true do |t|
    t.string "zip",     :limit => 5,  :null => false
    t.string "state",   :limit => 40
    t.string "county",  :limit => 90
    t.string "city",    :limit => 90
    t.string "statefp", :limit => 2
  end

  create_table "zip_state", :id => false, :force => true do |t|
    t.string "zip",     :limit => 5, :null => false
    t.string "stusps",  :limit => 2, :null => false
    t.string "statefp", :limit => 2
  end

  create_table "zip_state_loc", :id => false, :force => true do |t|
    t.string "zip",     :limit => 5,   :null => false
    t.string "stusps",  :limit => 2,   :null => false
    t.string "statefp", :limit => 2
    t.string "place",   :limit => 100, :null => false
  end

end
