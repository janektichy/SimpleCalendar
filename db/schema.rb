# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_01_160500) do
  create_table "event_series", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "occurrences_count", null: false
    t.date "repeat_ends_on", null: false
    t.string "repeat_frequency", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_event_series_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.boolean "all_day", default: false, null: false
    t.string "color", default: "slate", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.datetime "ends_at", null: false
    t.integer "event_series_id"
    t.string "location"
    t.datetime "starts_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["event_series_id"], name: "index_events_on_event_series_id"
    t.index ["user_id", "starts_at"], name: "index_events_on_user_id_and_starts_at"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "default_calendar_view", default: "month", null: false
    t.integer "default_upcoming_days", default: 1, null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "event_series", "users"
  add_foreign_key "events", "event_series"
  add_foreign_key "events", "users"
end
