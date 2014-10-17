ENV['RACK_ENV'] ||= 'development'

module Squareteam
  class Application
    CONFIG = OpenStruct.new

    def self.configure
      yield(CONFIG) if block_given?
    end

    def self.environment
      ENV['RACK_ENV']
    end
  end
end
