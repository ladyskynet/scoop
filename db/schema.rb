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

ActiveRecord::Schema.define(version: 20171203003448) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "articles", force: :cascade do |t|
    t.string "title"
    t.string "author"
    t.string "url"
    t.datetime "published"
    t.text "content"
    t.float "readability"
    t.integer "feed_id"
    t.integer "wordcount"
    t.float "sentimentality"
    t.float "bias"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "string_length"
    t.integer "letter_count"
    t.integer "syllable_count"
    t.integer "sentence_count"
    t.float "average_words_per_sentence"
    t.float "average_syllables_per_word"
  end

  create_table "feeds", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["url"], name: "feeds_url_key", unique: true
  end

  create_table "photos", force: :cascade do |t|
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "article_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.bigint "article_id"
    t.bigint "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["article_id"], name: "index_taggings_on_article_id"
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "photo_id"
    t.index ["name"], name: "index_tags_on_name"
  end

  add_foreign_key "taggings", "articles"
  add_foreign_key "taggings", "tags"
end
