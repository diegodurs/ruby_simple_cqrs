# interface
class EventStore
  def initialize
    @events = []
  end

  def save(event)
    @events << event
    self
  end

  def get(id, from_version)
    @events.select do |e|
      e.id == id && e.version >= from_version
    end
  end
end