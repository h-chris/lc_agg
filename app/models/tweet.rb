class Tweet < ActiveRecord::Base

  # screen_name
  # name
  # profile_image_url
  # tweeted_at
  # id_str
  # retweeted_status
  # r_screen_name
  # r_name
  # r_profile_image_url
  # text

  def update_t_db
    num_tweets = 20
    last_id    = Tweet.last.id_str.to_i

    # make request
    tweets = $client.user_timeline("LaunchCodeSTL", 
                                   include_rts: true, 
                                   include_entities: true, 
                                   count: num_tweets, 
                                   since_id: last_id)

    tweets.reverse_each do |tweet|
      insert_tweet(tweet) unless tweet['id'] == last_id
    end
  end

  def insert_tweet(obj)
    if obj['retweeted_status'].nil?
      rt =  nil 
      text = obj['text']
      urls = obj['urls']
      media = obj['media']
    else
      rt = get_rt_info(obj['retweeted_status']) 
      text  = rt[:r_text]
      urls  = rt[:r_urls]
      media = rt[:r_media]
    end

    listing = Tweet.new
    listing.screen_name         = obj['user']['screen_name']
    listing.name                = obj['user']['name']
    listing.profile_image_url   = obj['user']['profile_image_url'].to_s
    listing.tweeted_at          = obj['created_at']
    listing.id_str              = obj['id'].to_s
    listing.text                = parse_full_text(text, urls, media)
    listing.retweeted_status    = obj['retweeted_status']['id'].to_s
    listing.r_screen_name       = rt.nil? ? nil : rt[:r_screen_name]
    listing.r_name              = rt.nil? ? nil : rt[:r_name]
    listing.r_profile_image_url = rt.nil? ? nil : rt[:r_profile_image_url]
    listing.save!
  end

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
      if word.index(/https?:\/\//) == 0
        link_text = urls[links_index]['attrs'][:display_url]
        url = urls[links_index]['attrs'][:expanded_url]

        text_arr.fill(html_hash[:href_beg] + 
                      url + 
                      html_hash[:href_mid] + 
                      link_text + 
                      html_hash[:href_end], text_arr.index(word), 1)

        links_index += 1 if links_index < urls.count - 1
      end
    end # end each

    return parse_text(text_arr.join(' '), html_hash)
  end

  def parse_urls_and_media(text, urls, media, html_hash)
    return parse_urls(parse_media(text, media, html_hash), 
                      urls, 
                      html_hash)
  end

  def parse_text(text, html_hash)
    text_arr = text.split
  
    text_arr.each do |word|
      if word.index(/[@#]/) == 0
        # handle punctuation and link text
        symbol = word.slice(0)
        link_text = word.slice(/[^@#.,!]\w+/)  
        punc = word.slice(symbol.length + 
               link_text.length..word.length - 1)

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
                      html_hash[:span_end] + 
                      (punc.nil? ? "" : punc), text_arr.index(word), 1)

      end # end if
    end # end each

    return text_arr.join(' ')
  end

  def get_rt_info(rt_id)
    rt = $client.status(rt_id)
    rt_info = {
      r_screen_name: rt['user']['screen_name'],
      r_name: rt['user']['name'],
      r_profile_image_url: rt['user']['profile_image_url'].to_s,
      r_text: rt['text'],
      r_urls: rt['urls'],
      r_media: rt['media']
    }
 
    return rt_info
  end
end
