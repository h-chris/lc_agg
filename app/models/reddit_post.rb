class RedditPost < ActiveRecord::Base
  # var names
  # title
  # author
  # url
  # subreddit
  # permalink
  # is_self
  # created_utc
  # thumbnail
  # domain
  # name
  # text

  # data = results['data']['children'][0]['data']

  def update_r_db
    # get json data to use
    results = parseJSON

    # check that hash isn't nil
    return nil if results.nil?

    data = results['data']['children']

    # make sure that there is something to update
    (0..(data.count - 1)).reverse_each do |i|
      obj = data[i]['data']
      insert_listing(obj) unless obj.nil?
    end # end loop
  end

  def parseJSON

    # reddit url fragments
    reddit = "http://www.reddit.com/r/LaunchCodeCS50x/new/.json?before="
    last = RedditPost.last.name

    # url to use
    uri = URI.parse(reddit + last)

    # create http request from url
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)

    # store response data
    response = http.request(request)

    # store parsed data if request successful
    if response.code == "200"
      result = JSON.parse(response.body)
    # else set to nil
    else
      result = nil
    end

    # return object
    return result
  end

  def insert_listing(obj)
    listing = RedditPost.new
    listing.title     = obj['title']
    listing.author    = obj['author']
    listing.url       = obj['url']
    listing.subreddit = obj['subreddit']
    listing.permalink = obj['permalink']
    listing.is_self   = obj['is_self']
    listing.posted_at = Time.at(obj['created_utc']).utc
    listing.thumbnail = obj['thumbnail']
    listing.domain    = obj['domain']
    listing.name      = obj['name']
    listing.text      = obj['selftext']
    listing.save!
  end
end
