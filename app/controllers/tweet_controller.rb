class TweetController < ApplicationController
  def index
    Tweet.new.update_t_db
    @tweets  = Tweet.order('tweeted_at DESC').page params[:page]
  end
end
