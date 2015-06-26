require_relative './inventory_item/events'
require_relative './inventory_item/commands'
require_relative './inventory_item/commands_handler'
require_relative './inventory_item/root'
require_relative './inventory_item/repository'

require_relative './inventory_item/read/list_view'

module Test
  module App
    module InventoryItem
      class<<self
        attr_reader :repo
      end

      def self.main
        @repo = InventoryItem::Repository.new(App.storage, App.bus)

        commands = InventoryItem::CommandsHandler.new(@repo)
        App.bus.register_handler( InventoryItem::Create,       commands )
        App.bus.register_handler( InventoryItem::Deactivate,   commands )
        App.bus.register_handler( InventoryItem::Rename,       commands )

        list = InventoryItem::ListView.new
        App.bus.register_handler( InventoryItem::Created,      list )
        App.bus.register_handler( InventoryItem::Deactivated,  list )
        App.bus.register_handler( InventoryItem::Renamed,      list )
      end
    end
  end
end