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

ActiveRecord::Schema.define(version: 20160522015214) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contact_forms", force: :cascade do |t|
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "flagged_records", force: :cascade do |t|
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "flagging_agent"
    t.integer  "flagged_record_id"
  end

  create_table "record_attachments", force: :cascade do |t|
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "record_id"
    t.text     "annotation"
    t.text     "file_upload_url"
    t.string   "media_type"
    t.text     "cas_user_name"
    t.string   "placeholder_image_path"
    t.text     "image_upload_url"
    t.string   "mimetype"
    t.text     "filename"
  end

  create_table "records", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cas_user_name"
    t.text     "description"
    t.string   "location"
    t.string   "source_url"
    t.boolean  "release_checked"
    t.text     "date"
    t.text     "hashtag"
    t.boolean  "make_private"
    t.boolean  "flagged_for_removal"
  end

  create_table "users", force: :cascade do |t|
    t.string   "cas_user_name"
    t.boolean  "is_admin"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
