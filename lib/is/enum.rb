# encoding: utf-8

class Enum
   
  class << self
       
    private :new
   
  end
 
  attr_reader :name
 
  def initialize name, props = {}
    @name = name.intern
    props.each do |k, v|
      instance_variable_set "@#{k}".intern, v
    end
  end
    
end
