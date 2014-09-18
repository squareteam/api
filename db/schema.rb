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

ActiveRecord::Schema.define(version: 20140917211504) do

  create_table "knowledges", force: true do |t|
    t.string   "title",      limit: 100
    t.string   "file_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "missions", force: true do |t|
    t.string   "title",       limit: 125,             null: false
    t.text     "description"
    t.datetime "deadline"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id",                          null: false
    t.integer  "status",      limit: 1,   default: 0, null: false
    t.integer  "created_by",                          null: false
  end

  create_table "organizations", force: true do |t|
    t.string   "name",       limit: 125, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organizations", ["name"], name: "index_organizations_on_name", unique: true, using: :btree

  create_table "project_accesses", force: true do |t|
    t.string  "object_type", null: false
    t.integer "object_id",   null: false
    t.integer "project_id",  null: false
  end

  add_index "project_accesses", ["object_id", "object_type"], name: "index_project_accesses_on_object_id_and_object_type", using: :btree

  create_table "projects", force: true do |t|
    t.string   "title",       limit: 125,             null: false
    t.text     "description"
    t.datetime "deadline"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",      limit: 1,   default: 0, null: false
    t.integer  "owner_id",                            null: false
    t.string   "owner_type",                          null: false
  end

  create_table "task_comments", force: true do |t|
    t.string   "text",       limit: 5000, null: false
    t.integer  "task_id",                 null: false
    t.integer  "user_id",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "task_comments", ["task_id"], name: "index_task_comments_on_task_id", using: :btree

  create_table "tasks", force: true do |t|
    t.string   "title",       limit: 125,                  null: false
    t.string   "description", limit: 5000,                 null: false
    t.boolean  "closed",                   default: false
    t.datetime "deadline"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "mission_id",                               null: false
  end

  create_table "teams", force: true do |t|
    t.string   "name",            limit: 125,                     null: false
    t.integer  "organization_id",                                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_admin",                    default: false,     null: false
    t.string   "color",           limit: 7,   default: "#2cc1ff", null: false
  end

  add_index "teams", ["name", "organization_id"], name: "index_teams_on_name_and_organization_id", unique: true, using: :btree

  create_table "user_roles", force: true do |t|
    t.integer  "user_id",                           null: false
    t.integer  "team_id",                           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "permissions", limit: 8, default: 0, null: false
  end

  add_index "user_roles", ["user_id", "team_id"], name: "index_user_roles_on_user_id_and_team_id_and_role_id", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "name",       limit: 100, default: "", null: false
    t.string   "email",      limit: 100,              null: false
    t.binary   "pbkdf",      limit: 256,              null: false
    t.binary   "salt",       limit: 256,              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider",   limit: 100, default: "", null: false
    t.string   "uid",        limit: 254, default: "", null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true, using: :btree

end
