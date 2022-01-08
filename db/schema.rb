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

ActiveRecord::Schema.define(version: 2021_12_09_150156) do

  create_table "comments", force: :cascade do |t|
    t.string "message"
    t.integer "user_id"
    t.integer "moto_route_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["moto_route_id"], name: "index_comments_on_moto_route_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "moto_route_favourites", force: :cascade do |t|
    t.integer "user_id"
    t.integer "moto_route_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["moto_route_id"], name: "index_moto_route_favourites_on_moto_route_id"
    t.index ["user_id"], name: "index_moto_route_favourites_on_user_id"
  end

  create_table "moto_route_votes", force: :cascade do |t|
    t.integer "user_id"
    t.integer "moto_route_id"
    t.integer "score"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["moto_route_id"], name: "index_moto_route_votes_on_moto_route_id"
    t.index ["user_id"], name: "index_moto_route_votes_on_user_id"
  end

  create_table "moto_routes", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "coordinates_json_string"
    t.integer "date_open_day"
    t.integer "date_open_month"
    t.integer "date_closed_day"
    t.integer "date_closed_month"
    t.integer "time_to_complete_h"
    t.integer "time_to_complete_m"
    t.integer "difficulty"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.float "score", default: 0.0
    t.index ["user_id"], name: "index_moto_routes_on_user_id"
  end

  create_table "point_of_interests", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.float "latitude"
    t.float "longitude"
    t.integer "variant", default: 0
    t.integer "moto_route_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["moto_route_id"], name: "index_point_of_interests_on_moto_route_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "first_name"
    t.string "last_name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "comments", "moto_routes"
  add_foreign_key "comments", "users"
  add_foreign_key "moto_route_favourites", "moto_routes"
  add_foreign_key "moto_route_favourites", "users"
  add_foreign_key "moto_route_votes", "moto_routes"
  add_foreign_key "moto_route_votes", "users"
  add_foreign_key "moto_routes", "users"
  add_foreign_key "point_of_interests", "moto_routes"
end
