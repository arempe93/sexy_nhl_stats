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

ActiveRecord::Schema.define(version: 20150114163234) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: true do |t|
    t.integer  "nhl_id"
    t.datetime "game_time"
    t.integer  "home_team_id"
    t.integer  "home_team_score"
    t.integer  "away_team_id"
    t.integer  "away_team_score"
    t.string   "decision"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "goalie_stats", force: true do |t|
    t.integer  "game_id"
    t.integer  "player_id"
    t.integer  "team_id"
    t.integer  "shots_faced"
    t.integer  "saves"
    t.integer  "goals_against"
    t.time     "toi"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "players", force: true do |t|
    t.integer "nhl_id"
    t.integer "team_id"
    t.string  "name"
    t.integer "sweater"
    t.string  "player_type"
  end

  create_table "skater_stats", force: true do |t|
    t.integer  "game_id"
    t.integer  "player_id"
    t.integer  "team_id"
    t.integer  "goals"
    t.integer  "assists"
    t.integer  "shots"
    t.integer  "pim"
    t.integer  "pm"
    t.time     "toi"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "team_stats", force: true do |t|
    t.integer  "team_id"
    t.integer  "game_id"
    t.integer  "shots"
    t.integer  "blocks"
    t.integer  "pim"
    t.integer  "hits"
    t.integer  "fow"
    t.integer  "takeaways"
    t.integer  "giveaways"
    t.string   "penalties"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "goals"
    t.boolean  "winner"
  end

  create_table "teams", force: true do |t|
    t.integer  "nhl_id"
    t.string   "city"
    t.string   "name"
    t.string   "abbv"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "conference"
    t.string   "division"
    t.integer  "wins",       default: 0
    t.integer  "losses",     default: 0
    t.integer  "ot",         default: 0
    t.integer  "row",        default: 0
  end

end
