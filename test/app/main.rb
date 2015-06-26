require 'aggregate_root'
require 'command'
require 'event'
require 'event_store'
require 'fake_bus'
require 'repository'

require_relative 'inventory_item'

module Test
  module App
    class<<self
      attr_reader :bus, :storage
    end

    def self.main
      @bus = FakeBus.new
      @storage = EventStore.new

      InventoryItem.main
      # ServiceLocator.Bus = bus
    end
  end
end