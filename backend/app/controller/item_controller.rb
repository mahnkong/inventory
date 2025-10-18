module Inventory
  module Controller
    class ItemController

      require 'openfoodfacts'
      require 'pp'
      require_relative '../util/logging'
      require_relative '../storage/data_storage'
      require_relative '../storage/barcode_cache_storage'

      attr_reader :data

      def initialize
        @barcode_cache_storage = Inventory::Storage::BarcodeCacheStorage.new
        @data_storage = Inventory::Storage::DataStorage.new
      end

      def add_item_with_barcode(storage_id, barcode)
        barcode_cache = @barcode_cache_storage.load_data
        data = @data_storage.load_data
        Inventory::Util.logger.info "Add item with barcode #{barcode} at storage id #{storage_id}"
        data[storage_id] = {} unless data.key? storage_id
        begin
          product_name = barcode_cache[barcode]
          unless product_name
            product = Openfoodfacts::Product.get(barcode)
            if product
              product_name = "#{product.brands}"
              if product.product_name
                product_name << " '#{product.product_name}'"
              elsif product.generic_name
                product_name << " '#{product.generic_name}'"
              end
              @barcode_cache_storage.store_data(barcode_cache.merge({ barcode => product_name }))
            else
              return nil
            end
          end
          data[storage_id][barcode] = 0 unless data[storage_id].key? barcode
          data[storage_id][barcode] += 1
          @data_storage.store_data(data)
          return product_name
        rescue OpenURI::HTTPError => e
          Inventory::Util.logger.error "HTTP Error while fetching barcode info from api: #{e.message}"
          return nil
        end
      end

      def remove_item_with_barcode(storage_id, barcode)
        barcode_cache = @barcode_cache_storage.load_data
        data = @data_storage.load_data
        name = nil
        if data.key? storage_id and data[storage_id].key? barcode
          Inventory::Util.logger.info "remove item with barcode #{barcode} at storage id #{storage_id}"

          barcode_cache.each do |key, value|
            if key == barcode
              name = value
              break
            end
          end

          data[storage_id][barcode] -= 1
          if data[storage_id][barcode] == 0
            data[storage_id].delete(barcode)
          end
          @data_storage.store_data(data)
        end
        name ? name[0].upcase + name[1..] : nil
      end

      def get_items
        barcode_cache = @barcode_cache_storage.load_data
        data = @data_storage.load_data
        items = {}
        data.each do |storage_id, storage|
          items[storage_id] = {}
          storage.each do |barcode, amount|
            items[storage_id][barcode] = {}
            items[storage_id][barcode]['amount'] = amount
            items[storage_id][barcode]['name'] = barcode_cache[barcode][0].upcase + barcode_cache[barcode][1..]
          end
        end
        items
      end
    end
  end
end
