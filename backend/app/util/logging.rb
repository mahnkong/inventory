module Inventory
  module Util
    require 'logger'
    class << self; attr_accessor :logger; end
  end

  Util.logger = Logger.new(STDERR)
end
