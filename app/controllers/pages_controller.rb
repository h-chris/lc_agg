class PagesController < ApplicationController
  def latest
    @tweets  = Tweet.order('id')
    @reddits = RedditPost.all
  end

  def reddit
  end

  def twitter
  end

  def youtube
  end

  def about
  end

  def faq
  end
end
