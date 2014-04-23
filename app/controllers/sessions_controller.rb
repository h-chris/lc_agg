class SessionsController < ApplicationController
  def create
    authenticated_user = RedditKit::Client.new params[:username], 
                                               params[:password]
    if authenticated_user
      session[:username] = authenticated_user.username
      redirect_to reddit_path, notice: "Logged In!"
    else
      flash[:error] = "Wrong username or password."
      redirect_to reddit_path
    end
  end

  def destroy
    session[:username] = nil
    redirect_to reddit_path, notice: "Logged Out."
  end
end
