class PagesController < ApplicationController

  def latest
    max_latest = 10

    RedditPost.new.update_r_db
    Tweet.new.update_t_db
    Youtube.new.update_yt_db

    @latest = Array.new

    reddits  = RedditPost.order('posted_at DESC').limit(max_latest)
    tweets   = Tweet.order('tweeted_at DESC').limit(max_latest)
    youtubes = Youtube.order('created_at DESC').limit(max_latest)

    (1..max_latest).each do
      if reddits[0].posted_at > tweets[0].tweeted_at &&
         reddits[0].posted_at > youtubes[0].created_at
        @latest.push(reddits[0])
        reddits.shift
      elsif tweets[0].tweeted_at > reddits[0].posted_at &&
            tweets[0].tweeted_at > youtubes[0].created_at
        @latest.push(tweets[0])
        tweets.shift
      else
        @latest.push(youtubes[0])
        youtubes.shift
      end
    end
  end

  def about
  end
end
