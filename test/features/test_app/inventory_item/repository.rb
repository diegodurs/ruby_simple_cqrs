module TestApp
  module InventoryItem
    class Repository < ::Repository

      def initialize_aggregate
        InventoryItem::Root.new
      end

    end
  end
end