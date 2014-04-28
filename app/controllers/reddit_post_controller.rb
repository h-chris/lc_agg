class RedditPostController < ApplicationController

  def index
    @reddits = RedditPost.order('posted_at DESC').page params[:page]
  end

  def show
    @reddit_post = RedditPost.find(params[:id])
  end
end
