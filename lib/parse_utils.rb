module ParseUtils
  def parseJSON(url)

    # url to use
    uri = URI.parse(url)

    # create http request from url
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)

    # store response data
    response = http.request(request)

    # store parsed data if request successful
    if response.code == "200"
      result = JSON.parse(response.body)
    # else set to nil
    else
      result = nil
    end

    # return object
    return result
  end

end
