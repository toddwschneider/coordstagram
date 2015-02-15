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

ActiveRecord::Schema.define(version: 20150207190239) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "instagram_items", force: :cascade do |t|
    t.string   "instagram_id",                   null: false
    t.datetime "created_time",                   null: false
    t.string   "username",                       null: false
    t.string   "user_id",                        null: false
    t.string   "link",                           null: false
    t.string   "path",                           null: false
    t.float    "latitude",                       null: false
    t.float    "longitude",                      null: false
    t.float    "distance_from_center_in_meters", null: false
    t.string   "instagram_type",                 null: false
    t.string   "filter"
    t.text     "full_data",                      null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "instagram_items", ["created_time"], name: "index_instagram_items_on_created_time", using: :btree
  add_index "instagram_items", ["distance_from_center_in_meters", "created_time"], name: "index_on_distance_and_created", using: :btree
  add_index "instagram_items", ["instagram_id"], name: "index_instagram_items_on_instagram_id", unique: true, using: :btree
  add_index "instagram_items", ["latitude", "longitude"], name: "index_instagram_items_on_latitude_and_longitude", using: :btree
  add_index "instagram_items", ["path"], name: "index_instagram_items_on_path", using: :btree

end
