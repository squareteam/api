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

ActiveRecord::Schema.define(version: 20140209211623) do

  create_table "members", force: true do |t|
    t.integer  "organization_id",                 null: false
    t.integer  "user_id",                         null: false
    t.boolean  "admin",           default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "members", ["organization_id", "user_id"], name: "index_members_on_organization_id_and_user_id", unique: true, using: :btree

  create_table "organizations", force: true do |t|
    t.string   "name",       limit: 125, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organizations", ["name"], name: "index_organizations_on_name", unique: true, using: :btree

  create_table "roles", force: true do |t|
    t.string   "name",        limit: 125,             null: false
    t.integer  "team_id",                             null: false
    t.integer  "permissions", limit: 8,   default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "roles", ["name", "team_id"], name: "index_roles_on_name_and_team_id", unique: true, using: :btree

  create_table "teams", force: true do |t|
    t.string   "name",            limit: 125, null: false
    t.integer  "organization_id",             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "teams", ["name", "organization_id"], name: "index_teams_on_name_and_organization_id", unique: true, using: :btree
  add_index "teams", ["name"], name: "index_teams_on_name", unique: true, using: :btree

  create_table "user_roles", force: true do |t|
    t.integer  "user_id",    null: false
    t.integer  "role_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_roles", ["user_id", "role_id"], name: "index_user_roles_on_user_id_and_role_id", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "name",       limit: 100, default: "", null: false
    t.string   "email",      limit: 100,              null: false
    t.binary   "pbkdf",      limit: 256,              null: false
    t.binary   "salt",       limit: 256,              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree

end
