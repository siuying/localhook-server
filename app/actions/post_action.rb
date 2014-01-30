class PostAction < Cramp::Action
  PATH_REGEXP = %r{^/([^/]+)(.+)?$}

  def start
    begin
      data      = forwarded_data(request)
      response  = encode_json(data)
      channel   = channel_with_path(request.path)
      publish_data(channel, response)

    rescue ArgumentError => e
      render "ERROR: #{e}", 500

    end

    finish
  end

  # publish the data to redis channel
  def publish_data(channel, data)
    redis = EM::Hiredis.connect(Settings.redis)
    redis.publish(channel, data).callback do
      # only close connection after complete the publish
      redis.close_connection
    end
  end

  def forwarded_data(request)
    path     = forwarded_path_with_path(request.path)
    headers  = forwarded_headers(request.env)

    { 
      action: 'post', 
      path: path,
      query_string: request.query_string,
      body: request.body.string,
      headers: headers
    }
  end

  def channel_with_path(path)
    match = path.match PATH_REGEXP
    if match
      endpoint_name = match[1]
      return "webhook.#{endpoint_name}"
    else
      raise ArgumentError, "Invalid path: #{path}"
    end
  end

  private
  def forwarded_headers(headers)
    headers.select {|k,v| k.start_with? 'HTTP_'}
      .collect {|key, val| [key.sub(/^HTTP_/, ''), val] }
      .reject {|k,v| ["VERSION", "HOST"].include?(k) }
  end

  def forwarded_path_with_path(path)
    match = path.match PATH_REGEXP
    if match
      if match[2]
        return match[2]
      else
        return "/"
      end
    else
      raise ArgumentError, "Invalid path: #{path}"
    end
  end

  def encode_json(obj)
    Yajl::Encoder.encode(obj)
  end
end
