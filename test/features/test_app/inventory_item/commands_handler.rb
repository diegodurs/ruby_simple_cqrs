require 'active_support/core_ext/string'

# This is the mapping between command (possibly serialized) and domain methods
# it allows the domain to be kept clean for the extraction of command's arguments.
# It also manage aggregate version
module TestApp
  module InventoryItem
    class CommandsHandler
      def initialize(repository)
        @repository = repository
      end

      def handle(command)
        send(command.class.name.demodulize.underscore, command)
      end

      private

      def create(command)
        item = InventoryItem::Root.new
        item.create(command.id, command.name)

        @repository.save(item, -1)
      end

      def rename(command)
        item = @repository.find(command.id)
        item.rename(command.new_name)

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