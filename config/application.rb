module Squareteam
  class Application
    CONFIG = OpenStruct.new

    def self.configure
      yield(CONFIG) if block_given?
    end
  end
end