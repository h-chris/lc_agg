class PagesController < ApplicationController

  def latest
    RedditPost.new.update_r_db
    Tweet.new.update_t_db
    @reddits = RedditPost.order('posted_at DESC')
    @tweets  = Tweet.order('tweeted_at DESC')
    @yt = RedditPost.all.where('domain=? OR domain=?', 
                               'youtu.be', 'youtube.com')
    @yt_embed = "http://youtube.com/embed/"
    @yt_short = "http://youtu.be/"
    @yt_long  = "https://www.youtube.com/watch?v="
  end

  def youtube
  end

  def about
  end

  def faq
  end
end
