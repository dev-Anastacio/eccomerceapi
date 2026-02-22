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

ActiveRecord::Schema[8.1].define(version: 2026_02_22_024044) do
  create_table "abandoned_carts", force: :cascade do |t|
    t.integer "cart_id", null: false
    t.decimal "cart_total", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.integer "notification_count", default: 0
    t.datetime "notified_at"
    t.datetime "recovered_at"
    t.string "status", default: "pending"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["cart_id", "status"], name: "index_abandoned_carts_on_cart_id_and_status"
    t.index ["cart_id"], name: "index_abandoned_carts_on_cart_id"
    t.index ["notified_at"], name: "index_abandoned_carts_on_notified_at"
    t.index ["user_id"], name: "index_abandoned_carts_on_user_id"
  end

  create_table "cart_items", force: :cascade do |t|
    t.integer "cart_id"
    t.datetime "created_at", null: false
    t.integer "product_id"
    t.integer "quantity"
    t.datetime "updated_at", null: false
  end

  create_table "carts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.string "description"
    t.string "name"
    t.decimal "price"
    t.integer "stock"
    t.datetime "updated_at", null: false
    t.integer "user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "address"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "abandoned_carts", "carts"
  add_foreign_key "abandoned_carts", "users"
end
