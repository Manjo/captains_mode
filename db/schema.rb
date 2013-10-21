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

ActiveRecord::Schema.define(version: 20131020010445) do

  create_table "champion_bans", force: true do |t|
    t.integer  "champion_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "champion_picks", force: true do |t|
    t.integer  "champion_id"
    t.integer  "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "champions", force: true do |t|
    t.string   "name"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
  end

  create_table "lobbies", force: true do |t|
    t.string   "state"
    t.string   "team_one"
    t.string   "team_two"
    t.text     "bans_one"
    t.text     "bans_two"
    t.text     "picks_one"
    t.text     "picks_two"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teams", force: true do |t|
    t.string   "captain_id"
    t.integer  "lobby_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
