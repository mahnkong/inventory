module Inventory
  module Controller

    require "#{File.expand_path(File.dirname(__FILE__))}/../../app/controller/item_controller.rb"
    require 'test/unit'
    require 'mocha/test_unit'

    class ItemControllerTest < Test::Unit::TestCase

      def create_barcode_cache_mock
        mock_barcode_cache = mock('barcode_cache')

        Inventory::Storage::BarcodeCacheStorage
          .stubs(:new)
          .returns(mock_barcode_cache)

        mock_barcode_cache
      end

      def create_storage_mock
        mock_storage = mock('storage')

        Inventory::Storage::DataStorage
          .stubs(:new)
          .returns(mock_storage)

        mock_storage
      end

      def test_add_item_with_barcode
        barcode = "4251097410289"
        storage_id = "1"
        product = mock('product')
        product.stubs(:brands).returns("Mocked")
        product.stubs(:product_name).returns("Product")

        data = {}
        barcode_cache = {}

        mock_storage = create_storage_mock
        mock_storage.expects(:load_data).returns(data)
        mock_storage.expects(:store_data).returns(true)

        mock_barcode_cache = create_barcode_cache_mock
        mock_barcode_cache.expects(:load_data).returns(barcode_cache)
        mock_barcode_cache.expects(:store_data).returns(true)

        Openfoodfacts::Product.expects(:get).with(barcode).returns(product)

        item_controller = ItemController.new
        assert_same(false, data.key?(storage_id))
        item_controller.add_item_with_barcode(storage_id, barcode)
        assert_same(1, data[storage_id][barcode])
      end

      def test_remove_item_with_barcode
        barcode = "4251097410289"
        storage_id = "1"
        product = "Mocked Product"

        barcode_cache = {
          barcode => product
        }
        data = {
          storage_id => {
            barcode => 2
          }
        }


        mock_storage = create_storage_mock
        mock_storage.expects(:load_data).returns(data).twice
        mock_storage.expects(:store_data).returns(true).twice

        mock_barcode_cache = create_barcode_cache_mock
        mock_barcode_cache.expects(:load_data).returns(barcode_cache).twice

        item_controller = ItemController.new
        assert_same(2, data[storage_id][barcode])
        assert_same(product, item_controller.remove_item_with_barcode(storage_id, barcode))
        assert_same(1, data[storage_id][barcode])
        assert_same(product, item_controller.remove_item_with_barcode(storage_id, barcode))
        assert_same(false, data.key?(data[storage_id][barcode]))
      end
    end
  end
end
