class Repository
  def initialize(event_store, publisher)
    @event_store, @publisher = event_store, publisher
  end

  def save(aggregate, expected_version = nil)
    if expected_version && @event_store.get(aggregate.id, expected_version).any?
      fail 'concurency exception'
    end

    aggregate.uncommitted_changes.each_with_index do |e, i|
      e.id = aggregate.id if e.id.nil?
      fail 'no id' if e.id.nil?

      e.version = aggregate.version + (i + 1)
      e.timestamp = Time.now.utc.to_i

      @event_store.save(e)
      @publisher.publish(e)
    end

    aggregate.mark_changes_as_committed
  end

  def load(id)
    aggregate = initialize_aggregate

    history = @event_store.get(id, -1)
    fail 'aggregate not found' if history.empty?

    aggregate.load_from_history(history)
  end

  alias_method :find, :load
end