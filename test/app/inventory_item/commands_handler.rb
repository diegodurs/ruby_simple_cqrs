require 'active_support/core_ext/string'

module Test
  module App
    module InventoryItem
      class CommandsHandler
        def initialize(repository)
          @repository = repository
        end

        def handle(command)
          send(command.class.name.underscore)
        end

        private

        def create(command)
          item = InventoryItem.new(command.id, command.name)

          @repository.save(item, -1)
        end

        def rename(command)
          item = @repository.find(command.id)
          item.rename(command.name)

          @repository.save(item, command.original_version)
        end

        def deactivate(command)
          item = @repository.find(command.id)
          item.deactivate

          @repository.save(item, command.original_version)
        end
      end
    end
  end
end