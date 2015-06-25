module Test
  module App
    module InventoryItem
      class Created
        attr_reader :id, :name
        def initialize(id, name)
          @id, @name = id, name
        end
      end

      class Renamed
        attr_reader :id, :name
        def initialize(id, name)
          @id, @name = id, name
        end
      end

      class Deactivated
        attr_reader :id
        def initialize(id)
          @id = id
        end
      end
    end
  end
end
