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

ActiveRecord::Schema[7.2].define(version: 2024_11_15_022210) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "web_stats", force: :cascade do |t|
    t.text "url", null: false
    t.text "referrer"
    t.datetime "timestamp", null: false
    t.string "record_hash", limit: 32, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["referrer"], name: "index_web_stats_on_referrer", where: "(referrer IS NOT NULL)"
    t.index ["timestamp", "url", "referrer"], name: "index_web_stats_on_timestamp_url_referrer"
  end
end
