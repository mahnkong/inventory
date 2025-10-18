module Inventory
  module Controller
    class ConfigController

      require_relative '../util/logging'

      attr_reader :config

      def initialize
        @config_file = ENV['INVENTORY_CONFIG_FILE']
        @config = {}
      end

      def get_config
        if @config.empty?
          if @config_file && File.exist?(@config_file)
            @config = YAML.load_file @config_file
          else
            Inventory::Util.logger.error "Invalid value for config file (INVENTORY_CONFIG_FILE=#{@config_file})!"
          end
        end
        @config
      end

    end
  end
end
