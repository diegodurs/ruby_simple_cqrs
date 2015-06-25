require 'active_support/core_ext/string'

class AggregateRoot
  attr_reader :id, :version

  # uncommitted_changes should be locked when apply_change is called
  attr_reader :uncommitted_changes

  def mark_changes_as_committed
    @uncommitted_changes = []
    self
  end

  def load_from_history(history)
    history.each do |event|
      if event.version != @version + 1
        raise EventsOutOfOrderException.new(@id)
      end
      apply_change(e, false)
    end
    self
  end

  def apply_change(event, is_new = true)
    mutex.synchronize do
      send("on_#{event.class.underscore}", event)
      if is_new
        @uncommitted_changes << event
      else
        @version += 1
        @id = event.id # wtf ?
      end
    end
    self
  end

  private

  def mutex
    @mutex = Mutex.new
  end
end