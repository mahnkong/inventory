module Inventory
  module Storage

    require_relative 'base_storage'

    class DataStorage < BaseStorage

      def initialize
        super('data')
      end

    end
  end
end
