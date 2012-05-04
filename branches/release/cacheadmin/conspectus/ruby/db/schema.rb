# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110411145212) do

  create_table "archival_units", :force => true do |t|
    t.integer  "collection_id"
    t.string   "param_values"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "au_state_id"
    t.boolean  "off_line",      :default => false
    t.string   "lockss_au_id"
  end

  add_index "archival_units", ["collection_id"], :name => "index_archival_units_on_collection_id"

  create_table "archive_status_items", :force => true do |t|
    t.integer  "archive_id"
    t.string   "cache"
    t.integer  "size",       :limit => 8, :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "archives", :force => true do |t|
    t.string   "title",              :limit => 5
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "create_url_pattern"
    t.string   "update_url_pattern"
    t.string   "show_url_pattern"
  end

  add_index "archives", ["title"], :name => "index_archives_on_title"

  create_table "au_states", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "level"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "irreversible", :default => true
  end

  create_table "collection_status_items", :force => true do |t|
    t.integer  "collection_id"
    t.string   "cache"
    t.integer  "size",          :limit => 8, :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "disk_usage",                 :default => 0.0
  end

  create_table "collections", :force => true do |t|
    t.integer  "archive_id"
    t.integer  "plugin_id"
    t.string   "title"
    t.text     "description"
    t.string   "base_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "remote_id"
    t.boolean  "retired",     :default => false
  end

  add_index "collections", ["archive_id"], :name => "index_collections_on_archive_id"
  add_index "collections", ["plugin_id"], :name => "index_collections_on_plugin_id"
  add_index "collections", ["title"], :name => "index_collections_on_title"

  create_table "content_provider_status_items", :force => true do |t|
    t.integer  "content_provider_id"
    t.string   "cache"
    t.integer  "size",                :limit => 8, :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "content_providers", :force => true do |t|
    t.string   "name"
    t.string   "plugin_prefix"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "icon_url"
    t.string   "acronym",               :limit => 5
    t.integer  "placeholder_plugin_id"
    t.boolean  "retired",                            :default => false
  end

  add_index "content_providers", ["acronym"], :name => "index_content_providers_on_acronym"
  add_index "content_providers", ["name"], :name => "index_content_providers_on_name"

  create_table "globals", :force => true do |t|
    t.string "name"
    t.text   "value"
  end

  create_table "plugin_params", :force => true do |t|
    t.integer  "plugin_id"
    t.string   "name"
    t.string   "kind"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "descr"
  end

  add_index "plugin_params", ["plugin_id"], :name => "index_plugin_params_on_plugin_id"

  create_table "plugins", :force => true do |t|
    t.integer  "content_provider_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "retired",             :default => false
  end

  add_index "plugins", ["content_provider_id"], :name => "index_plugins_on_content_provider_id"

  create_table "preservation_status_items", :force => true do |t|
    t.integer  "archival_unit_id"
    t.string   "cache"
    t.string   "hostname"
    t.integer  "ui_port"
    t.float    "disk_usage"
    t.integer  "size",               :limit => 8
    t.datetime "last_crawl"
    t.string   "last_crawl_result"
    t.datetime "last_crawl_attempt"
    t.datetime "last_poll"
    t.integer  "num_recent_polls"
    t.float    "agreement"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "login",                                   :null => false
    t.string   "crypted_password",                        :null => false
    t.string   "password_salt",                           :null => false
    t.string   "persistence_token",                       :null => false
    t.integer  "login_count",         :default => 0,      :null => false
    t.datetime "last_request_at"
    t.datetime "last_login_at"
    t.datetime "current_login_at"
    t.string   "last_login_ip"
    t.string   "current_login_ip"
    t.string   "email",               :default => "",     :null => false
    t.string   "first_name",          :default => "",     :null => false
    t.string   "last_name",           :default => "",     :null => false
    t.string   "rights",              :default => "view", :null => false
    t.integer  "content_provider_id"
  end

  add_index "users", ["last_request_at"], :name => "index_users_on_last_request_at"
  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"

end
