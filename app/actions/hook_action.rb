# A hook action listen for webhook channel for update
# and push any changes to client
class HookAction < Cramp::Action
  self.transport = :sse

  keep_connection_alive

  on_start :validate_connection, :subscribe_webhook
  on_finish :unsubscribe_webhook

  # if configured tokens setting, and if user has not supplied with correct token, abort the request and return NO.
  # otherwise, return YES.
  def validate_connection
    if Settings.tokens.size > 0
      request_token = request.params["token"] || request.env["HTTP_AUTHORIZATION"]
      if request_token.nil?
        render "missing token", event: :error
        finish
        return false
      elsif !Settings.tokens.include?(request_token)
        render "invalid token #{request_token}", event: :error
        finish
        return false
      end
    end

    return true
  end

  # Subscribe redis on webhook channel
  def subscribe_webhook
    @redis = EM::Hiredis.connect(Settings.redis)
    @pubsub = @redis.pubsub
    @pubsub.subscribe('webhook')
    @pubsub.on(:message) do |channel, message|
      render(message)
    end
  end

  # Unsubscribe webhook channel and disconnect from redis
  def unsubscribe_webhook
    @redis.pubsub.unsubscribe('webhook')
    @redis.close_connection
  end

  private
  def encode_json(obj)
    Yajl::Encoder.encode(obj)
  end
end
