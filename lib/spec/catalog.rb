module PuppetSpec
  class Catalog
    attr_accessor :catalog
     
    def self.setup(catalog)
     @instance = new(catalog)
     instance
    end
     
    def self.instance
      @instance
    end
     
    def initialize(catalog)
      @catalog = catalog
    end
  end
end
