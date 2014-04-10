class Tweet < ActiveRecord::Base

  # screen_name
  # name
  # tweeted_at
  # id_str
  # retweeted_status
  # profile_image_url
  # text

  def parse_full_text(text, urls, media)
    html_hash = {
      href_beg: "<a href=\"",
      href_mid: "\" target=\"_blank\">",
      href_end: "</a>",
      twitter_url: "https://twitter.com/",
      hash_pre: "search?q=%23",
      hash_post: "src=hash",
      span_beg: "<span class=\"athash\">",
      span_end: "</span>"
    }

    # check for urls && media
    if !urls.empty? && !media.empty?
      return parse_urls_and_media(text, urls, media, html_hash)
    # check for urls
    elsif !urls.empty?
      return parse_urls(text, urls, html_hash)
    # check for media
    elsif !media.empty?
      return parse_media(text, media, html_hash)
    # no urls || media
    else
      return parse_text(text, html_hash)
    end
  end


  def parse_media(text, media, html_hash)
    # make sure link is https
    url = media[0][:media_url].to_s.index(/https:\/\//) == nil ?
          media[0][:media_url].to_s.insert(4, 's') :
          media[0][:media_url].to_s

    text_arr = text.split

    text_arr.each do |word|
      link_text = media[0][:display_url]

      if word.index(/http:\/\//) == 0 &&
         word === media[0][:url].to_s
        
        text_arr.fill(html_hash[:href_beg] + 
                      url + 
                      html_hash[:href_mid] + 
                      link_text + 
                      html_hash[:href_end], text_arr.index(word), 1)
      end
    end # end each

    return parse_text(text_arr.join(' '), html_hash)
  end

  def parse_urls(text, urls, html_hash)
    links_index = 0

    text_arr = text.split

    text_arr.each do |word|
      link_text = urls[links_index]['attrs'][:display_url]
      url = urls[links_index]['attrs'][:expanded_url]

      if word.index(/http:\/\//) == 0

        text_arr.fill(html_hash[:href_beg] + 
                      url + 
                      html_hash[:href_mid] + 
                      link_text + 
                      html_hash[:href_end], text_arr.index(word), 1)

        links_index += 1
      end
    end # end each

    return parse_text(text_arr.join(' '), html_hash)
  end

  def parse_text(text, html_hash)
    text_arr = text.split
  
    text_arr.each do |word|
      # handle punctuation
      if word.index(/[^a-zA-Z0-9_]/) == word.length - 1
        link_text = word.slice(1..word.length - 2)  
        punc = word.slice(1..word.length - 1)
      else
        link_text = word.slice(1..word.length - 1)  
        punc = ""
      end

      symbol = word.slice(0)

      if word.index(/[@#]/) == 0
        case symbol
        when "@"
          hash_pre  = ""
          hash_post = ""
        else
          hash_pre  = html_hash[:hash_pre]
          hash_post = html_hash[:hash_post]
        end

        text_arr.fill(html_hash[:span_beg] +
                      symbol + 
                      html_hash[:href_beg] + html_hash[:twitter_url] + 
                      hash_pre + link_text + hash_post + 
                      html_hash[:href_mid] + 
                      link_text + 
                      html_hash[:href_end] +
                      html_hash[:span_end] + punc, text_arr.index(word), 1)

      end # end if
    end # end each

    return text_arr.join(' ')
  end
end
