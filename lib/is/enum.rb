# encoding: utf-8

class Enum
   
  class << self
   
    include Enumerable

    private :new
   
    def [] name
    end
    
    def each &block
    end
   
  end
  
  include Comparable
 
  attr_reader :name
 
  def initialize name, props = {}
    @name = name.intern
    props.each do |k, v|
      instance_variable_set "@#{k}".intern, v
    end
    this = self
    self.class.define_singleton_method @name do
      this
    end
  end
    
end
