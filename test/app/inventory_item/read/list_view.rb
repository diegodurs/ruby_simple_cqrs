require_relative './list_dto'
require 'app/bull_shit_database'

module Test
  module App
    module InventoryItem
      class ListView
        def handle(event)
          send("on_#{event.class.name.demodulize.underscore}", event)
        end

        def on_created(event)
          BullShitDatabase.list.add(
            InventoryItem::ListDto.new(event.id, event.name)
          )
        end

        def on_renamed(event)
          item = BullShitDatabase.list.select do |x|
            x.id == event.id
          end.first

          item.name = event.new_name
        end

        def on_deactivated(event)
          BullShitDatabase.list.remove_all do |x|
            x.id == event.id
          end
        end
      end
    end
  end
end