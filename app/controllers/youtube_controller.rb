class YoutubeController < ApplicationController
  def index
    Youtube.new.update_yt_db
    @youtubes = Youtube.all.page params[:page]
  end
end
