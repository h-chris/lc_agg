class RedditPostController < ApplicationController

  def index
    @reddits = RedditPost.order('id DESC').page params[:page]
  end

  def show
    @reddit_post = RedditPost.find(params[:id])
  end
end
