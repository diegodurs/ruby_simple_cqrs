require 'coveralls'
Coveralls.wear!

require 'minitest/autorun'
require 'byebug'

require_relative './app/main'

module Test
  module App
    describe InventoryItem do
      def handle(e)
        @events ||= []
        @events << e
      end

      before do
        Test::App.main
        App.bus.register_handler(InventoryItem::Created, self)

        cmd = InventoryItem::Create.new(1, 'test')
        App.bus.send_cmd(cmd)
      end

      describe 'cmd Create' do

        it 'publish an event' do
          refute @events.empty?

          item = InventoryItem.repo.load(1)

          assert 'test', item.name
          assert 1, item.id
          assert_equal 0, item.version
          refute item.deactivated
        end

        it 'creates a list view representation' do

          refute BullShitDatabase.list.empty?

          item = BullShitDatabase.list.first

          assert 'test', item.name
          assert 1, item.id
          assert_raises NoMethodError do
            item.version
          end

        end
      end

      describe 'cmd Rename' do
        it 'update name and version' do
          cmd = InventoryItem::Rename.new(1, 'testChanged')
          App.bus.send_cmd(cmd)

          item = InventoryItem.repo.load(1)

          assert 'testChanged', item.name
          assert_equal 1, item.version
        end
      end

      describe 'cmd Deactivate' do
        it 'remote entries for that item' do
          cmd = InventoryItem::Create.new(2, 'other')
          App.bus.send_cmd(cmd)

          refute BullShitDatabase.list.empty?

          cmd = InventoryItem::Deactivate.new(1)
          App.bus.send_cmd(cmd)

          assert BullShitDatabase.list.find {|i| i.id == 2 }
          refute BullShitDatabase.list.find {|i| i.id == 1 }
        end
      end
    end
  end
end
