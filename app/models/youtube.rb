class Youtube < ActiveRecord::Base
  require 'open-uri'
  require 'parse_utils'
  include ParseUtils

  # title
  # thumb
  # url
  # embed_id
  # tags
  # lesson
  # description

  paginates_per 10

  def update_yt_db
    lctv = "http://tv.launchcode.us/rest/videos1.json"

    # get data to use
    results = parseJSON(lctv) if valid_json? lctv

    # check that hash isn't nil
    return nil if results.nil?

    # make sure there are new entries
    if results.count > Youtube.all.count
      # loop through results
      results.each do |obj| 
        new_entries = true

        # make sure that only new entries are entered
        Youtube.all.each {|yt| new_entries = false if yt.title == obj['title']}

        # insert if new
        insert_listing(obj) if new_entries
      end
    end
  end

  def insert_listing(obj)
    embed = obj['url'].split("//www.youtube.com/embed/")[1]

    listing = Youtube.new
    listing.title       = obj['title']
    listing.url         = obj['url']
    listing.embed_id    = embed
    listing.thumb       = obj['thumb'].index("img/") == 0 ? 
                            "http://img.youtube.com/vi/#{embed}/0.jpg" :
                            obj['thumb']
    listing.tags        = obj['tags']
    listing.lesson      = obj['lesson']
    listing.description = obj['description']

    listing.save
  end
end
