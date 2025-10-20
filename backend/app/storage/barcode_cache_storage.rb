module Inventory
  module Storage

    require_relative 'base_storage'

    class BarcodeCacheStorage < BaseStorage

      def initialize
        super('barcode_cache')
      end

    end
  end
end
