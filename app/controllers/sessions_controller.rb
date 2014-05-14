class SessionsController < ApplicationController
  def create
    auth_user = RedditKit::Client.new params[:username], 
                                      params[:password]
    if auth_user
      session[:username] = auth_user.username
      session[:password] = auth_user.as_json['password']
      redirect_to reddit_path, notice: "Logged In!"
    else
      flash[:error] = "Wrong username or password."
      redirect_to reddit_login_path
    end
  end

  def destroy
    session[:username] = nil
    session[:password] = nil
    redirect_to reddit_path, notice: "Logged Out."
  end
end
