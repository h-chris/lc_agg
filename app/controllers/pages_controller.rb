class PagesController < ApplicationController

  def latest
    RedditPost.new.update_r_db
    Tweet.new.update_t_db
    @reddits = RedditPost.order('posted_at DESC')
    @tweets  = Tweet.order('tweeted_at DESC')
  end

  def youtube
  end

  def about
  end

  def faq
  end
end
