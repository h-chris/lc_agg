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

ActiveRecord::Schema.define(version: 20140516120824) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "reddit_posts", force: true do |t|
    t.string   "title"
    t.string   "author"
    t.string   "url"
    t.string   "subreddit"
    t.string   "permalink"
    t.datetime "posted_at"
    t.string   "thumbnail"
    t.string   "domain"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "text"
    t.boolean  "is_self"
  end

  create_table "tweets", force: true do |t|
    t.string   "screen_name"
    t.string   "name"
    t.datetime "tweeted_at"
    t.string   "id_str"
    t.string   "retweeted_status"
    t.string   "profile_image_url"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "r_screen_name"
    t.string   "r_name"
    t.string   "r_profile_image_url"
  end

  create_table "youtubes", force: true do |t|
    t.string   "title"
    t.string   "thumb"
    t.string   "url"
    t.string   "embed_id"
    t.string   "tags"
    t.string   "lesson"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
