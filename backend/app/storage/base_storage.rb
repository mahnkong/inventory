module Inventory
  module Storage
    class BaseStorage

      require 'yaml'

      def initialize(filename)
        @filename = filename
        @data_dir = ENV['INVENTORY_DATA_DIR'] || 'data'
        @data_file = "#{@data_dir}/#{@filename}.yml"
        @data_lock_file = "#{@data_file}.lock"
      end

      def store_data(data)
        File.open(@data_lock_file , "w") do |lock|
          lock.flock(File::LOCK_EX)

          tmp = Tempfile.new("#{@filename}_temp", @data_dir)
          File.open(tmp, "w") { |f| f.write(data.to_yaml) }
          File.rename(tmp, @data_file)
        end
      end

      def load_data
        File.open(@data_lock_file, "w") do |lock_file|
          lock_file.flock(File::LOCK_SH)

          if File.exist? @data_file
            YAML.load_file @data_file
          else
            {}
          end
        end
      end
    end
  end
end
