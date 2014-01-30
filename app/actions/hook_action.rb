# A hook action listen for webhook channel for update
# and push any changes to client
class HookAction < Cramp::Action
  self.transport = :sse

  keep_connection_alive

  attr_reader :endpoint
  on_start :validate_connection, :subscribe_webhook
  on_finish :unsubscribe_webhook

  # if configured tokens setting, and if user has not supplied with correct token, abort the request and return NO.
  # otherwise, return YES.
  def validate_connection
    request_token = request.params["token"] || request.env["HTTP_AUTHORIZATION"]
    unless request_token
      render "missing token", event: :error
      finish
      return false
    end

    service = Localhook::EndpointService.new
    @endpoint = service.endpoint_with_token(request_token)
    unless @endpoint
      render "invalid token #{request_token}", event: :error
      finish
      return false
    end

    render @endpoint.name, event: :endpoint
    return true
  end

  # Subscribe redis on webhook channel
  def subscribe_webhook
    @redis = EM::Hiredis.connect(Settings.redis)
    pubsub = @redis.pubsub
    pubsub.subscribe(subscribed_channel)
    pubsub.on(:message) do |channel, message|
      render(message, event: :webhook)
    end
  end

  # Unsubscribe webhook channel and disconnect from redis
  def unsubscribe_webhook
    if @redis
      @redis.pubsub.unsubscribe(subscribed_channel)
      @redis.close_connection
    end
  end

  def subscribed_channel
    "webhook.#{endpoint.name}"
  end

  private
  def encode_json(obj)
    Yajl::Encoder.encode(obj)
  end
end
