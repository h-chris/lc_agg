class PagesController < ApplicationController

  def latest
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
    @user = User.new
  end
end
