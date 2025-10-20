module Inventory
  module Controller

    require "#{File.expand_path(File.dirname(__FILE__))}/../../app/controller/item_controller.rb"
    require 'test/unit'
    require 'mocha/test_unit'

    class ItemControllerTest < Test::Unit::TestCase
      def test_add_item_with_barcode

        data = {}
        barcode_cache = {}

        mock_storage = mock('storage')
        mock_storage.expects(:load_data).returns(data)
        mock_storage.expects(:store_data).returns(true)

        Inventory::Storage::DataStorage
          .stubs(:new)
          .returns(mock_storage)

        mock_barcode_cache = mock('barcode_cache')
        mock_barcode_cache.expects(:load_data).returns(barcode_cache)
        mock_barcode_cache.expects(:store_data).returns(true)

        Inventory::Storage::BarcodeCacheStorage
          .stubs(:new)
          .returns(mock_barcode_cache)

        item_controller = ItemController.new
        assert_same(false, data.key?('1'))
        item_controller.add_item_with_barcode("1", "4251097410289")
        assert_same(1, data["1"]["4251097410289"])
      end

      def test_remove_item_with_barcode

        barcode_cache = {
          "4251097410289" => 'Bifi roll'
        }
        data = {
          '1' => {
            "4251097410289" => 2
          }
        }

        mock_storage = mock('storage')
        mock_storage.expects(:load_data).returns(data).twice
        mock_storage.expects(:store_data).returns(true).twice

        Inventory::Storage::DataStorage
          .stubs(:new)
          .returns(mock_storage)

        mock_barcode_cache = mock('barcode_cache')
        mock_barcode_cache.expects(:load_data).returns(barcode_cache).twice

        Inventory::Storage::BarcodeCacheStorage
          .stubs(:new)
          .returns(mock_barcode_cache)

        item_controller = ItemController.new
        assert_same(2, data['1']['4251097410289'])
        item_controller.remove_item_with_barcode('1', '4251097410289')
        assert_same(1, data['1']['4251097410289'])
        item_controller.remove_item_with_barcode('1', '4251097410289')
        assert_same(false, data.key?(data['1']['4251097410289']))
      end
    end
  end
end
