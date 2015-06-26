require 'active_support/core_ext/string'

module AggregateRoot

  def self.included(base)
    base.send(:attr_reader, :id)
  end

  def version
    @version ||= -1
  end

  def uncommitted_changes
    @uncommitted_changes ||= []
  end

  def mark_changes_as_committed
    @uncommitted_changes = []
    self
  end

  def load_from_history(history)
    history.each do |event|
      if event.version != version + 1
        raise 'EventsOutOfOrderException'
      end
      apply_change(event, false)
    end
    self
  end

  def apply_change(event, is_new = true)
    mutex.synchronize do
      send("on_#{event.class.name.demodulize.underscore}", event)
      if is_new
        self.uncommitted_changes << event
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