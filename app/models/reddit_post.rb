class RedditPost < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  require 'parse_utils'
  include ParseUtils

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

  paginates_per 10

  def update_r_db

    # reddit url fragments
    reddit = "http://www.reddit.com/r/LaunchCodeCS50x/new/.json?before="
    url = reddit + RedditPost.last.name
    
    # get json data to use
    results = parseJSON(url)

    # check that hash isn't nil
    return nil if results.nil?

    data = results['data']['children']

    # make sure that there is something to update
    (0..(data.count - 1)).reverse_each do |i|
      obj = data[i]['data']
      insert_listing(obj) unless obj.nil?
    end # end loop
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

  def prep_reddit_post(item)
    r_url = "http://www.reddit.com"
    domain = r_url + 
             (item.domain.index("self") == 0 ? "/r/#{item.subreddit}" :
                                              "/domain/#{item.domain}")
    time_ago = time_ago_in_words(item.posted_at)
    author_link = r_url + "/u/#{item.author}"
    output = 
    "<div class=\"post\">" +
      "<span class=\"post_title\">" + 
        "<a href=\"#{item.url}\">#{item.title}</a>" + 
      "</span>" +
      "<span class=\"post_domain\">" +
        " (<a href=\"#{domain}\">#{item.domain}</a>)" +
      "</span><br/>" +
      "<span class=\"post_byline\">" +
        "submitted #{time_ago} by <a href=\"#{author_link}\">" + 
                                    item.author +
                                  "</a>" +
      "</span><br/>" +
    "</div>"
    return output
  end

  def num_comments(post)
    return RedditKit.link(post.name).num_comments.to_s
  end
end
