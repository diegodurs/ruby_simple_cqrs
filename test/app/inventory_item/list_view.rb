module Test
  module App
    module InventoryItem
      class ListView
        def on_created(event)
          BullShitDatabase.list.add(
            InventoryItemListDto.new(event.id, event.name)
          )
        end

        def on_renamed(event)
          item = BullShitDatabase.list.select do |x|
            x.id == event.id
          end

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