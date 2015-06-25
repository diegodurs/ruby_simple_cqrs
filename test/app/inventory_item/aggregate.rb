require 'test/app/inventory_item/events'

module Test
  module App
    module InventoryItem
      class Aggregate < ::AggregateRoot
        def create(id, name)
          apply_change(InventoryItem::Created.new(id, name))
        end

        def deactivate
          fail "already deactivated" if(!@activated)
          apply_change(InventoryItem::Deactivated.new(@id)
        end

        def rename(name)
          fail 'invalid name' if name.nil? || name == ''
          apply_change(InventoryItem::Renamed.new(@id, name))
        end

        private

        def on_created(event)
          @id = event.id
          @name = event.name
          @deactivated = false
        end

        def on_deactivated(event)
          @deactivated = true
        end

        def on_renamed(event)
          @name = event.name
        end
      end
    end
  end
end