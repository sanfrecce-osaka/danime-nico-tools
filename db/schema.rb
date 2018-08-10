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

ActiveRecord::Schema.define(version: 2018_06_26_104155) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "episodes", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "number_in_season"
    t.integer "overall_number", null: false
    t.integer "default_thread_id", null: false
    t.string "thumbnail_url"
    t.string "content_id"
    t.bigint "season_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["content_id"], name: "index_episodes_on_content_id"
    t.index ["season_id"], name: "index_episodes_on_season_id"
    t.index ["title"], name: "index_episodes_on_title"
  end

  create_table "seasons", force: :cascade do |t|
    t.string "title"
    t.boolean "watchable", default: false, null: false
    t.string "thumbnail_url"
    t.text "outline"
    t.text "cast"
    t.text "staff"
    t.integer "produced_year"
    t.string "copyright"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["produced_year"], name: "index_seasons_on_produced_year"
    t.index ["title"], name: "index_seasons_on_title"
  end

  add_foreign_key "episodes", "seasons"
end
