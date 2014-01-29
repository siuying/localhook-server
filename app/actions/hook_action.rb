# A hook action listen for webhook channel for update
# and push any changes to client
class HookAction < Cramp::Action
  self.transport = :sse

  keep_connection_alive

  on_start :create_redis
  on_finish :destroy_redis

  def create_redis
    @redis = EM::Hiredis.connect(Settings.redis)
    @pubsub = @redis.pubsub
    @pubsub.subscribe('webhook')
    @pubsub.on(:message) do |channel, message|
      render(encode_json(message))
    end
  end

  def destroy_redis
    @redis.pubsub.unsubscribe('webhook')
  end

  private
  def encode_json(obj)
    Yajl::Encoder.encode(obj)
  end
end
