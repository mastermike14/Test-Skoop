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

ActiveRecord::Schema.define(:version => 20100324001714) do

  create_table "admins", :force => true do |t|
    t.string  "firstname"
    t.string  "lastname"
    t.string  "uid"
    t.string  "email"
    t.integer "access"
  end

  create_table "four_oh_fours", :force => true do |t|
    t.string   "host"
    t.string   "path"
    t.string   "referer"
    t.integer  "count",      :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "four_oh_fours", ["host", "path", "referer"], :name => "index_four_oh_fours_on_host_and_path_and_referer", :unique => true
  add_index "four_oh_fours", ["path"], :name => "index_four_oh_fours_on_path"

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.string   "owner"
    t.string   "desc"
    t.integer  "twitter_id"
    t.string   "atoken"
    t.string   "asecret"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups_users", :id => false, :force => true do |t|
    t.integer "group_id", :null => false
    t.integer "user_id",  :null => false
  end

  add_index "groups_users", ["group_id", "user_id"], :name => "index_groups_users_on_group_id_and_user_id", :unique => true

  create_table "parents", :force => true do |t|
    t.string   "email"
    t.string   "asecret"
    t.string   "atoken"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "user_id"
  end

  add_index "parents", ["user_id"], :name => "index_parents_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "firstname"
    t.string   "lastname"
    t.string   "uid"
    t.string   "email"
    t.string   "asecret"
    t.string   "atoken"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
