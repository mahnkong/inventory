module Inventory
  module Controller

    require "#{File.expand_path(File.dirname(__FILE__))}/../../app/controller/item_controller.rb"
    require 'test/unit'
    require 'mocha/test_unit'

    class ItemControllerTest < Test::Unit::TestCase
      def test_add_item_with_barcode

        data = {}

        mock_storage = mock('storage')
        mock_storage.expects(:load_data).returns(data)
        mock_storage.expects(:store_data).returns(true)

        Inventory::Storage::DataStorage
          .stubs(:new)
          .returns(mock_storage)

        item_controller = ItemController.new
        assert_same(false, data.key?('Bifi roll'))
        item_controller.add_item_with_barcode(4251097410289)
        assert_same(1, data['Bifi roll'])
      end

      def test_remove_item_with_name

        data = {
          'Bifi roll' => 2,
        }

        mock_storage = mock('storage')
        mock_storage.expects(:load_data).returns(data).times(2)
        mock_storage.expects(:store_data).returns(true).times(2)

        Inventory::Storage::DataStorage
          .stubs(:new)
          .returns(mock_storage)

        item_controller = ItemController.new
        assert_same(2, data['Bifi roll'])
        item_controller.remove_item_with_name('Bifi roll')
        assert_same(1, data['Bifi roll'])
        item_controller.remove_item_with_name('Bifi roll')
        assert_same(false, data.key?('Bifi roll'))
      end
    end
  end
end
