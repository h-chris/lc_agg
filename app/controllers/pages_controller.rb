class PagesController < ApplicationController

  def latest
  end

  def reddit
    @reddits = RedditPost.order('id DESC').page params[:page]
  end

  def twitter
    @tweets  = Tweet.order('id DESC').page params[:page]
  end

  def youtube
  end

  def about
  end

  def faq
  end

  def login
    @reddit = RedditKit::Client.new
  end
end
