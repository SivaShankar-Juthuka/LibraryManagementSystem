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

ActiveRecord::Schema[7.1].define(version: 2024_06_27_074749) do
  create_table "admins", force: :cascade do |t|
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_admins_on_user_id"
  end

  create_table "black_list_tokens", force: :cascade do |t|
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "book_copies", force: :cascade do |t|
    t.integer "book_id", null: false
    t.boolean "is_damaged"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "copy_number"
    t.boolean "is_available", default: true
    t.index ["book_id"], name: "index_book_copies_on_book_id"
  end

  create_table "book_inventories", force: :cascade do |t|
    t.integer "book_id", null: false
    t.integer "library_id", null: false
    t.integer "available_copies"
    t.integer "copies_borrowed"
    t.integer "copies_reserved"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_book_inventories_on_book_id"
    t.index ["library_id"], name: "index_book_inventories_on_library_id"
  end

  create_table "books", force: :cascade do |t|
    t.string "title"
    t.string "author"
    t.string "isbn"
    t.integer "published_at"
    t.string "genre"
    t.integer "copy_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "borrows", force: :cascade do |t|
    t.integer "member_id", null: false
    t.integer "book_id", null: false
    t.integer "issued_copy"
    t.datetime "borrowed_at"
    t.datetime "due_date"
    t.datetime "returned_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_borrows_on_book_id"
    t.index ["member_id"], name: "index_borrows_on_member_id"
  end

  create_table "fine_rates", force: :cascade do |t|
    t.integer "library_id", null: false
    t.string "fine_type"
    t.float "fine_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["library_id"], name: "index_fine_rates_on_library_id"
  end

  create_table "fines", force: :cascade do |t|
    t.integer "member_id", null: false
    t.integer "borrow_id", null: false
    t.float "fine_amount"
    t.boolean "paid_status", default: false
    t.datetime "paid_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "fine_type"
    t.index ["borrow_id"], name: "index_fines_on_borrow_id"
    t.index ["member_id"], name: "index_fines_on_member_id"
  end

  create_table "librarians", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "library_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["library_id"], name: "index_librarians_on_library_id"
    t.index ["user_id"], name: "index_librarians_on_user_id"
  end

  create_table "libraries", force: :cascade do |t|
    t.string "library_name"
    t.string "library_address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "members", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "borrowing_limit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "library_id"
    t.index ["library_id"], name: "index_members_on_library_id"
    t.index ["user_id"], name: "index_members_on_user_id"
  end

  create_table "requests", force: :cascade do |t|
    t.integer "member_id", null: false
    t.integer "book_id", null: false
    t.datetime "requested_at"
    t.boolean "is_approved", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["book_id"], name: "index_requests_on_book_id"
    t.index ["member_id"], name: "index_requests_on_member_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "user_name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_assigned", default: false
  end

  add_foreign_key "admins", "users"
  add_foreign_key "book_copies", "books"
  add_foreign_key "book_inventories", "books"
  add_foreign_key "book_inventories", "libraries"
  add_foreign_key "borrows", "books"
  add_foreign_key "borrows", "members"
  add_foreign_key "fine_rates", "libraries"
  add_foreign_key "fines", "borrows"
  add_foreign_key "fines", "members"
  add_foreign_key "librarians", "libraries"
  add_foreign_key "librarians", "users"
  add_foreign_key "members", "libraries"
  add_foreign_key "members", "users"
  add_foreign_key "requests", "books"
  add_foreign_key "requests", "members"
end
