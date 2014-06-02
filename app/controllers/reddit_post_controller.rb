class RedditPostController < ApplicationController
  require 'parse_utils'
  include ParseUtils

  def index
    RedditPost.new.update_r_db
    @reddits = RedditPost.order('posted_at DESC').page params[:page]
    @after = RedditPost.find(@reddits.first.id + 1).name unless 
      @reddits.first.id == RedditPost.last.id
  end

  def show
    @reddit_post = RedditPost.find_by name: params[:name]
  end

  def login
    redirect_to reddit_path if current_user
  end

  def pm
    if current_user
      @author  = params[:author] if params[:author]
      @subject = params[:subject] if params[:subject]
      auth_user = RedditKit::Client.new session[:username], session[:password]
      @captcha = auth_user.new_captcha_identifier if auth_user.needs_captcha?
    else
      flash[:error] = "You must be logged in to send a private message."
      redirect_to reddit_login_path
    end
  end

  def send_reddit_pm
    if RedditKit.user params[:recipient]
      options = Hash.new
      auth_user = RedditKit::Client.new session[:username], session[:password]
      options[:subject] = params[:subject]

      if auth_user.needs_captcha?
        options[:captcha_identifier] = params[:captcha_id]
        options[:captcha_value] = params[:captcha_value]
      end

      auth_user.send_message params[:message], params[:recipient], options
      redirect_to reddit_path
    else
      flash[:error] = "Unable to find that user."
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

  def new_link
    if current_user
      auth_user = RedditKit::Client.new session[:username], session[:password]

      @captcha = auth_user.needs_captcha? ? auth_user.new_captcha_identifier : nil
    else
      session[:error] = "You must be logged in to submit a new link."
      redirect_to reddit_login_path
    end
  end

  def submit_reddit_link
    if current_user
      auth_user = RedditKit::Client.new session[:username], session[:password]

      options = Hash.new

      options[:url]  = (params[:url] == "" ? nil : params[:url])
      options[:text] = params[:text]
      options[:save] = true

      if auth_user.needs_captcha?
        options[:captcha_identifier] = params[:captcha_id]
        options[:captcha_value] = params[:captcha_value]
      end

      if auth_user
        success = auth_user.submit(params[:title], params[:subreddit], options)
      else
        flash[:error] = "An Error occured. Please Try Again."
      end
    end

    redirect_to reddit_path
  end

  def captcha
    redirect_to :back unless current_user
    @captcha = RedditKit.client.new_captcha_identifier
  end

  def search
    @pset = params[:pset] if params[:pset]
    @sets = JSON.parse(IO.read('data/psets.json'))
  end

  def unread
    if current_user
      auth_user = RedditKit::Client.new session[:username], session[:password]

      options = Hash.new
      options[:category] = "unread"
      options[:mark] = false

      @unread = auth_user.messages(options) if auth_user
    else
      redirect_to reddit_path
    end
  end

  def mark_read
    if current_user
      auth_user = RedditKit::Client.new session[:username], session[:password]

      if params[:names]
        params[:names].each do |name|
          auth_user.mark_as_read(name)
        end
      else
        redirect_to :back
      end
    else
      redirect_to :back
    end
  end
end
