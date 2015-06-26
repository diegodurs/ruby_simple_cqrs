require 'event'

module Test
  module App
    module InventoryItem
      Created = ::Event.new(:id, :name)
      Renamed = ::Event.new(:id, :new_name)
      Deactivated = ::Event.new(:id)
    end
  end
end