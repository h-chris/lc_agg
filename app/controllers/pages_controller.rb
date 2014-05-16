class PagesController < ApplicationController

  def latest
    RedditPost.new.update_r_db
    Tweet.new.update_t_db
<<<<<<< HEAD
    @reddits = RedditPost.order('posted_at DESC')
    @tweets  = Tweet.order('tweeted_at DESC')
  end
=======
    Youtube.new.update_yt_db
>>>>>>> add_youtube_videos

    @reddits  = RedditPost.order('posted_at DESC')
    @tweets   = Tweet.order('tweeted_at DESC')
    @youtubes = Youtube.all
  end

  def about
  end

  def faq
  end
end
