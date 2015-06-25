class FakeBus
  # message can be an Event or Command
  def register_handler(message_class, handler)
    handlers ||= {}
    handlers[message_class.name] ||= []
    handlers[message_class.name] << handler
  end

  def send(command)
    if handlers[command.class.name].any?
      fail 'cannot send commands to more than one handler' if handlers[command.class.name].count > 1
      handlers[command.class.name].first.handle(command)
    else
      fail 'no handler'
    end
  end

  def publish(event)
    handlers[event.class.name].each do |handler|
      handler.handle(event)
    end
  end
end