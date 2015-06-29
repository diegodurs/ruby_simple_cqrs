require_relative './inventory_item/events'
require_relative './inventory_item/commands'
require_relative './inventory_item/commands_handler'
require_relative './inventory_item/root'
require_relative './inventory_item/repository'

require_relative './inventory_item/read/list_view'

module TestApp
  module InventoryItem
    class<<self
      attr_reader :repo
    end

    def self.main
      @repo = InventoryItem::Repository.new(TestApp.storage, TestApp.bus)

      commands = InventoryItem::CommandsHandler.new(@repo)
      TestApp.bus.register_handler( InventoryItem::Create,       commands )
      TestApp.bus.register_handler( InventoryItem::Deactivate,   commands )
      TestApp.bus.register_handler( InventoryItem::Rename,       commands )

      list = InventoryItem::ListView.new
      TestApp.bus.register_handler( InventoryItem::Created,      list )
      TestApp.bus.register_handler( InventoryItem::Deactivated,  list )
      TestApp.bus.register_handler( InventoryItem::Renamed,      list )
    end
  end
end