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

ActiveRecord::Schema[8.0].define(version: 2025_10_10_083426) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "achievements", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "category"
    t.string "progress_type"
    t.integer "progress_target"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "articles", force: :cascade do |t|
    t.bigint "day_id", null: false
    t.string "title"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["day_id"], name: "index_articles_on_day_id"
  end

  create_table "content_items", force: :cascade do |t|
    t.bigint "day_id", null: false
    t.bigint "article_id"
    t.string "kind"
    t.string "title"
    t.text "body"
    t.string "url"
    t.integer "position"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_content_items_on_article_id"
    t.index ["day_id", "position"], name: "index_content_items_on_day_id_and_position"
    t.index ["day_id"], name: "index_content_items_on_day_id"
    t.index ["kind"], name: "index_content_items_on_kind"
  end

  create_table "days", force: :cascade do |t|
    t.integer "number"
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["number"], name: "index_days_on_number", unique: true
  end

  create_table "user_achievements", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "achievement_id", null: false
    t.integer "progress"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["achievement_id"], name: "index_user_achievements_on_achievement_id"
    t.index ["user_id"], name: "index_user_achievements_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "email_verified", default: false
    t.string "verification_code"
    t.datetime "verification_code_expires_at"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "articles", "days"
  add_foreign_key "content_items", "articles"
  add_foreign_key "content_items", "days"
  add_foreign_key "user_achievements", "achievements"
  add_foreign_key "user_achievements", "users"
end
