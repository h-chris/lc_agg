class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def markdown(text)
    Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, 
                            tables: true).render(text)
  end

  def prep_latest(list)
    html_out = Array.new
    list.each do |item|
      case item.class.to_s 
      when "RedditPost"
        html_out.push(item.prep_reddit_post(item))
      when "Tweet"
        html_out.push(item.prep_tweet(item))
      else
      end
    end
    return html_out
  end

  helper_method :markdown, :prep_latest
end
