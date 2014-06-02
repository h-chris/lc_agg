class YoutubeController < ApplicationController
  def index
    Youtube.new.update_yt_db
    @youtubes = Youtube.order('id DESC').page params[:page]
  end
end
