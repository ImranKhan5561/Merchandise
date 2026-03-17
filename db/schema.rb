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

ActiveRecord::Schema[8.1].define(version: 2026_02_07_160000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "parent_id"
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_categories_on_parent_id"
  end

  create_table "option_types", force: :cascade do |t|
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.string "name"
    t.string "presentation"
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_option_types_on_category_id"
  end

  create_table "option_values", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "option_type_id", null: false
    t.string "presentation"
    t.datetime "updated_at", null: false
    t.string "value"
    t.index ["option_type_id"], name: "index_option_values_on_option_type_id"
  end

  create_table "option_values_variants", id: false, force: :cascade do |t|
    t.bigint "option_value_id", null: false
    t.bigint "variant_id", null: false
    t.index ["option_value_id", "variant_id"], name: "index_option_values_variants_on_option_value_id_and_variant_id"
    t.index ["variant_id", "option_value_id"], name: "index_option_values_variants_on_variant_id_and_option_value_id"
  end

  create_table "product_option_types", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_visual", default: false
    t.bigint "option_type_id", null: false
    t.integer "position", default: 0
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_type_id"], name: "index_product_option_types_on_option_type_id"
    t.index ["product_id", "option_type_id"], name: "index_product_option_types_on_product_id_and_option_type_id", unique: true
    t.index ["product_id"], name: "index_product_option_types_on_product_id"
  end

  create_table "product_option_values", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_visual", default: false
    t.bigint "option_value_id", null: false
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.index ["option_value_id"], name: "index_product_option_values_on_option_value_id"
    t.index ["product_id", "option_value_id"], name: "idx_product_option_values_unique", unique: true
    t.index ["product_id"], name: "index_product_option_values_on_product_id"
  end

  create_table "product_specifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.string "value"
    t.index ["product_id"], name: "index_product_specifications_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.boolean "active", default: true
    t.decimal "base_price", precision: 10, scale: 2
    t.string "brand"
    t.bigint "category_id", null: false
    t.decimal "compare_at_price", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "discount_percentage"
    t.boolean "featured", default: false
    t.string "name"
    t.string "product_type"
    t.string "slug"
    t.integer "total_stock"
    t.datetime "updated_at", null: false
    t.bigint "visual_option_type_id"
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["slug"], name: "index_products_on_slug", unique: true
    t.index ["visual_option_type_id"], name: "index_products_on_visual_option_type_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "jti", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "variant_image_sets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "option_value_ids_key", null: false
    t.bigint "product_id", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "option_value_ids_key"], name: "idx_variant_image_sets_unique", unique: true
    t.index ["product_id"], name: "index_variant_image_sets_on_product_id"
  end

  create_table "variants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_master", default: false
    t.decimal "price", precision: 10, scale: 2
    t.bigint "product_id", null: false
    t.string "sku"
    t.integer "stock_quantity"
    t.datetime "updated_at", null: false
    t.decimal "weight", precision: 10, scale: 2
    t.index ["product_id"], name: "index_variants_on_product_id"
    t.index ["sku"], name: "index_variants_on_sku", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "option_types", "categories"
  add_foreign_key "option_values", "option_types"
  add_foreign_key "product_option_types", "option_types"
  add_foreign_key "product_option_types", "products"
  add_foreign_key "product_option_values", "option_values"
  add_foreign_key "product_option_values", "products"
  add_foreign_key "product_specifications", "products"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "option_types", column: "visual_option_type_id"
  add_foreign_key "variant_image_sets", "products"
  add_foreign_key "variants", "products"
end
