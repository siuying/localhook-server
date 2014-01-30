# A hook action listen for webhook channel for update
# and push any changes to client
class HookAction < Cramp::Action
  self.transport = :sse

  keep_connection_alive

  on_start :subscribe_webhook
  on_finish :unsubscribe_webhook

  def subscribe_webhook
    @redis = EM::Hiredis.connect(Settings.redis)
    @pubsub = @redis.pubsub
    @pubsub.subscribe('webhook')
    @pubsub.on(:message) do |channel, message|
      render(encode_json(message))
    end
  end

  def unsubscribe_webhook
    @redis.pubsub.unsubscribe('webhook')
    @redis.close_connection
  end

  private
  def encode_json(obj)
    Yajl::Encoder.encode(obj)
  end
end
