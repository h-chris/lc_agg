class RedditPost < ActiveRecord::Base
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

  def parse_urls(text)
    html_hash = {
      href_beg: "<a href=\"",
      href_mid: "\" target=\"_blank\">",
      href_end: "</a>",
    }

    text_arr = text.split

    text_arr.each do |word|
      if word.index(/http:\/\//) == 0
        text_arr.fill(html_hash[:href_beg] + 
                      word + 
                      html_hash[:href_mid] + 
                      word + 
                      html_hash[:href_end], text_arr.index(word), 1)

      end
    end # end each

    return text_arr.join(' ')
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
    listing.thumb     = obj['thumbnail']
    listing.domain    = obj['domain']
    listing.name      = obj['name']
    listing.text      = obj['selftext']
    listing.save!
  end
end
