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

      def test_modify_barcode_mapping_new_entry
        barcode = "4251097410289"
        new_product_name = "Testproduct"
        barcode_cache = {}
        mock_barcode_cache = create_barcode_cache_mock
        mock_barcode_cache.expects(:load_data).returns(barcode_cache)
        mock_barcode_cache.expects(:store_data).with do |data|
          barcode_cache = data
        end

        item_controller = ItemController.new

        item_controller.modify_barcode_mapping(barcode, new_product_name)
        assert_equal(new_product_name, barcode_cache[barcode])
      end


      def test_modify_barcode_mapping_existing_entry
        barcode = "4251097410289"
        old_product_name = "Testproduct"
        new_product_name = "Newproduct"
        barcode_cache = {
          barcode => old_product_name
        }
        mock_barcode_cache = create_barcode_cache_mock
        mock_barcode_cache.expects(:load_data).returns(barcode_cache)
        mock_barcode_cache.expects(:store_data).with do |data|
          barcode_cache = data
        end

        item_controller = ItemController.new

        item_controller.modify_barcode_mapping(barcode, new_product_name)
        assert_equal(new_product_name, barcode_cache[barcode])
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
        mock_barcode_cache.expects(:load_data).returns(barcode_cache).twice
        mock_barcode_cache.expects(:store_data).returns(true)

        Openfoodfacts::Product.expects(:get).with(barcode).returns(product)

        item_controller = ItemController.new
        assert_equal(false, data.key?(storage_id))
        item_controller.add_item_with_barcode(storage_id, barcode)
        assert_equal(1, data[storage_id][barcode])
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
        assert_equal(2, data[storage_id][barcode])
        assert_equal(product, item_controller.remove_item_with_barcode(storage_id, barcode))
        assert_equal(1, data[storage_id][barcode])
        assert_equal(product, item_controller.remove_item_with_barcode(storage_id, barcode))
        assert_equal(false, data.key?(data[storage_id][barcode]))
      end
    end
  end
end
