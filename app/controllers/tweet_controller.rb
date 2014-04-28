class TweetController < ApplicationController
  def index
    @tweets  = Tweet.order('tweeted_at DESC').page params[:page]
  end
end
