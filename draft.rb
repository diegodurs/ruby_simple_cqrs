# Commands of Inventory
# notice that create command does not have original_version, and that it receives the id

module SimpleCQRS
  class Command
    attr_accessor :expected_version
  end

  class DeactivateInventoryItem < Command
    def initialize(inventory_item_id, original_version)
      @inventory_item_id = inventory_item_id
      @original_version = original_version
    end
  end

  class CreateInventoryItem < Command
    def initialize(inventory_item_id, name)
      @inventory_item_id = inventory_item_id
      @name = name
    end
  end

  class RenameInventoryItem < Command
    def initialize(inventory_item_id, new_name, original_version)
      @inventory_item_id = inventory_item_id
      @new_name = new_name
      @original_version = original_version
    end
  end
end

# CommandHanlders of Inventory
module SimpleCQRS
  class InventoryCommandHandlers
    def initialize(repository)
      @repository = repository
    end

    def handle(command)
      case command.class
      when CreateInventoryItem
        create_inventory_item(command)
      when DeactivateInventoryItem
        deactivate_inventory_item(command)
      end
    end

    def create_inventory_item(command)
      item = InventoryItem.new(message.inventory_item_id, message.name)

      @repository.save(item, -1)
    end

    def deactivate_inventory_item(command)
      item = @repository.find_by_id(message.inventory_item_id)
      item.deactivate()

      @repository.save(item, message.orign)
    end
  end
end

# InventoryItem
module SimpleCQRS
  class InventoryItem < AggregateRoot
    def create(id, name)
      apply_change(InventoryItemCreated.new(id, name))
    end

    def deactivate
      if(!@activated) raise InvalidOperationException("already deactivated")
      apply_change(InventoryItemDeactivated.new(@id)
    end
  end

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
        send("on_#{event.name}", event)
        if is_new
          @uncommitted_changes << event
        else
          @version += 1
          # @id = event.id # wtf ?
        end
      end
      self
    end

    def mutex
      @mutex = Mutex.new
    end
  end
end

module SimpleCQRS
  # interface
  class EventStore
    def initialize
      @events = []
    end

    def save(event)
      @events << event
    end

    def get(id, from_version)
      @events.select do |e|
        e.id == id && e.version >= from_version
      end
    end
  end

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

        e.version = aggregate.version + i
        e.timestamp = Time.now.to_utc.to_i
        @event_store.save(e)
        publisher.publish(e)
      end

      aggregate.mark_changes_as_committed
    end

    def load(id)
      aggregate = AggregateFactory.create_aggregate(self.class)

      history = @event_store.get(id, -1)
      fail 'aggregate not found' if history.empty?

      aggregate.load_from_history(history)
    end
  end

  class AggregateFactory
    def self.create_aggregate(klass)
      klass.constantize.new
    end
  end

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
end


module SimpleCQRS
  InventoryItemListDto = Struct.new(:id, :name)

  class InventoryListView
    def on_created(message)
      BullShitDatabase.list.add(
        InventoryItemListDto.new(message.id, message.name)
      )
    end

    def on_renamed(message)
      item = BullShitDatabase.list.select do |x|
        x.id == message.id
      end

      item.name = message.new_name
    end

    def on_deactivated(message)
      BullShitDatabase.list.remove_all do |x|
        x.id == message.id
      end
    end
  end
end


# Start application

bus = FakeBus.new

storage = EventStore.new(bus)
rep = Repository.new(storage)

commands = InventoryCommandHandlers.new(rep)
bus.RegisterHandler( CheckInItemsToInventory,   commands.handle )
bus.RegisterHandler( CreateInventoryItem,       commands.handle )
bus.RegisterHandler( DeactivateInventoryItem,   commands.handle )
bus.RegisterHandler( RemoveItemsFromInventory,  commands.handle )
bus.RegisterHandler( RenameInventoryItem,       commands.handle )

detail = InvenotryItemDetailView.new
bus.RegisterHandler( InventoryItemCreated,      detail.handle )
bus.RegisterHandler( InventoryItemDeactivated,  detail.handle )
bus.RegisterHandler( InventoryItemRenamed,      detail.handle )
bus.RegisterHandler( ItemsCheckedInToInventory, detail.handle )
bus.RegisterHandler( ItemsRemovedFromInventory, detail.handle )

list = InventoryListView.new
bus.RegisterHandler( InventoryItemCreated,      list.handle )
bus.RegisterHandler( InventoryItemRenamed,      list.handle )
bus.RegisterHandler( InventoryItemDeactivated,  list.handle )

ServiceLocator.Bus = bus