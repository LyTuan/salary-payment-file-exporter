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

ActiveRecord::Schema[8.0].define(version: 2025_08_30_091147) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "exported_files", force: :cascade do |t|
    t.string "filepath"
    t.datetime "exported_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "employee_id"
    t.string "bank_bsb"
    t.string "bank_account"
    t.integer "amount_cents"
    t.string "currency"
    t.date "pay_date"
    t.integer "status", default: 0, null: false
    t.bigint "exported_file_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_payments_on_company_id"
    t.index ["exported_file_id"], name: "index_payments_on_exported_file_id"
    t.index ["status", "pay_date"], name: "index_payments_on_status_and_pay_date"
    t.index ["status"], name: "index_payments_on_status"
  end

  add_foreign_key "payments", "companies"
  add_foreign_key "payments", "exported_files"
end
