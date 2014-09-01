# encoding: utf-8

class Enum
   
  class << self
   
    include Enumerable

    private :new
   
    def [] name
    end
    
    def each &block
    end
    
    def value name, props = {}
      new name, props
    end
   
  end
  
  include Comparable
 
  attr_reader :name
  attr_reader :id
 
  def initialize name, props = {}
    @name = name.intern
    props.each do |k, v|
      instance_variable_set "@#{k}".intern, v
    end
    this = self
    self.class.define_singleton_method @name do
      this
    end
    @@vals ||= {}
    @@vals[self.class.name.intern] ||= {}
    @@vals[self.class.name.intern][@name] = self
  end
    
end
