module Test
  module App
    module InventoryItem
      class Deactivate < Command
        def initialize(id, original_version)
          @id = id
          @original_version = original_version
        end
      end

      class Create < Command
        def initialize(id, name)
          @id = id
          @name = name
        end
      end

      class Rename < Command
        def initialize(id, new_name, original_version)
          @id = id
          @new_name = new_name
          @original_version = original_version
        end
      end

      class Deactivate < Command
        def initialize(id, original_version)
          @id = id
          @original_version = original_version
        end
      end
    end
  end
end