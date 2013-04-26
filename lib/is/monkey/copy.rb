# encoding: utf-8

class Object

  # @return [Object]
  def copy
    Marshal.load(Marshal.dump(self))
  end

end
