module Test
  module App
    def self.main
      bus = FakeBus.new

      storage = EventStore.new(bus)
      rep = InventoryItem::Repository.new(storage)

      commands = InventoryItem::CommandHandlers.new(rep)
      bus.register_handler( CheckInItemsToInventory,   commands )
      bus.register_handler( CreateInventoryItem,       commands )
      bus.register_handler( DeactivateInventoryItem,   commands )
      bus.register_handler( RemoveItemsFromInventory,  commands )
      bus.register_handler( RenameInventoryItem,       commands )

      list = InventoryItem::ListView.new
      bus.register_handler( InventoryItemCreated,      list )
      bus.register_handler( InventoryItemRenamed,      list )
      bus.register_handler( InventoryItemDeactivated,  list )

      # ServiceLocator.Bus = bus
    end
  end
end