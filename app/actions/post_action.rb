class PostAction < Cramp::Action
  def start
    data = { 
      action: 'post', 
      path: request.path,
      query_string: request.query_string,
      body: request.body.string,
      headers: forward_headers
    }
    response = encode_json(data)

    redis = EM::Hiredis.connect(Settings.redis)
    redis.publish 'webhook', response

    finish
  end

  private
  def forward_headers
    request.env.select {|k,v| k.start_with? 'HTTP_'}
      .collect {|key, val| [key.sub(/^HTTP_/, ''), val] }
      .reject {|k,v| ["VERSION", "HOST"].include?(k) }
  end

  def encode_json(obj)
    Yajl::Encoder.encode(obj)
  end
end
