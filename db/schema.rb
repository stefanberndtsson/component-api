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

ActiveRecord::Schema.define(version: 20141022210828) do

  create_table "amounts", force: true do |t|
    t.text     "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "can_have_spares"
    t.boolean  "must_have_value"
  end

  create_table "asset_data", force: true do |t|
    t.integer  "asset_data_type_id"
    t.text     "name"
    t.text     "path"
    t.integer  "component_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "content_type"
  end

  create_table "asset_data_types", force: true do |t|
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "dir"
  end

  create_table "component_tags", force: true do |t|
    t.integer  "component_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "components", force: true do |t|
    t.text     "name"
    t.text     "description"
    t.integer  "amount_id"
    t.integer  "amount_value"
    t.boolean  "spares"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", force: true do |t|
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "norm"
  end

  create_table "users", force: true do |t|
    t.text     "username"
    t.text     "password"
    t.text     "name"
    t.text     "token"
    t.datetime "token_expire"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
