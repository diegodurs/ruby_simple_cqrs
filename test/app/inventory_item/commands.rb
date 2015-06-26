module Test
  module App
    module InventoryItem
      Deactivate = Command.new(:id, :original_version)
      Create = Command.new(:id, :name)
      Rename = Command.new(:id, :new_name, :original_version)
    end
  end
end