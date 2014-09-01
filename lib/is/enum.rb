# encoding: utf-8

class Enum
   
 class << self
       
   private :new
   
   def attr name
     attr_reader name
   end
       
 end
    
end
