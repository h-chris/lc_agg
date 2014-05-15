class RedditPostController < ApplicationController

  def index
    RedditPost.new.update_r_db
    @reddits = RedditPost.order('posted_at DESC').page params[:page]
    @after = RedditPost.find(@reddits.first.id + 1).name unless 
      @reddits.first.id == RedditPost.last.id
  end

  def show
    @reddit_post = RedditPost.find(params[:id])
  end

  def login
    redirect_to reddit_path if current_user
  end

  def pm
    if current_user
      @author = params[:author] if params[:author]
      auth_user = RedditKit::Client.new session[:username], session[:password]
      if auth_user.needs_captcha?
        session[:captcha_id]  = auth_user.new_captcha_identifier
        @captcha_url = auth_user.captcha_url(session[:captcha_id])
      else
        @captcha_url = nil
      end
    else
      flash[:error] = "You must be logged in to send a private message."
      redirect_to reddit_login_path
    end
  end

  def send_reddit_pm
    if RedditKit.user params[:recipient]
      auth_user = RedditKit::Client.new session[:username], session[:password]
      captcha_id = session[:captcha_id]
      session[:captcha_id] = nil
      auth_user.send_message params[:message], params[:recipient], 
                            {subject: params[:subject], 
                             captcha_identifier: captcha_id, 
                             captcha_value: params[:captcha_value]}
      redirect_to reddit_path
    else
      flash[:error] = "Unable to find that user."
      session[:captcha_id] = nil
      redirect_to reddit_pm_path
    end
  end

  def send_reddit_comment
    if current_user
      auth_user = RedditKit::Client.new session[:username], session[:password]

      if auth_user
        success = auth_user.submit_comment(params[:fullname], params[:message])
        
        if success
          flash[:notice] = "Successfully sent comment."
        else
          flash[:error] = "Unable to Send. Please Try Again Later."
        end
      else
        flash[:error] = "Unable to Send. Please Try Again Later."
      end
    end

    flash[:error] = "You Must Be Logged In to Comment."
    redirect_to :back
  end
end
