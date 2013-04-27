# encoding: utf-8

class Object

  # @return [Proc, nil]
  def to_proc
    if respond_to? :call
      method(:call).to_proc
    else
      nil
    end
  end

end
