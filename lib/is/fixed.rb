# encoding: utf-8

class Fixed < Numeric

  class << self

    attr_accessor :precision

    def precision= value
      if @precision
        raise 'Already defined.'
      elsif self == Fixed
        raise 'Fixed is an abstract class.'
      else
        @precision = value
      end
    end

    def subclass precision
      @@classes ||= []
      if ! @@classes[precision]
        @@classes[precision] = Class.new(Fixed)
        @@classes[precision].precision = precision
      end
      @@classes[precision]
    end

    def number value, precision
      subclass(precision).new(value)
    end

    def [] value
      self.new value
    end

    def to_s
      name || "Fixed(#{@precision})"
    end

  end

  attr_reader :precision
  attr_reader :number

  def precision
    self.class.precision
  end

  def initialize number = 0, shift = nil
    if ! precision
      raise 'Undefined precision.'
    end
    case number
    when Fixed
      np = number.precision + (shift || 0)
      if np = precision
        @number = number.number
      elsif np < precision
        @number = number.number * 10 ** (precision - np)
      else
        nn = number.number.divmod(10 ** (np - precision))
        @number = nn[0] + (nn[1] < 5 && 0 || 1)
      end
    when Integer
      np = (shift || 0)
      if np == precision
        @number = number
      elsif np < precision
        @number = number * 10 ** (precision - np)
      else
        nn = number.divmod(10 ** (np - precision))
        @number = nn[0] + (nn[1] < 5 && 0 || 1)
      end
    else
      np = (shift || 0)
      @number = (Float(number) * Float(10) ** (precision - np)).round
    end
  end

  def +@
    self
  end

  def -@
    self.class.new -@number, precision
  end

  def + other
    other = self.class.new other
    self.class.new(@number + other.number, precision)
  end

  def - other
    self + (-other)
  end

  def * other
  end

  def / other
  end

  def ** other
  end

  def to_s
    s = @number.to_s
    l = s.length
    if l <= precision
      s = '0' * (precision - l + 1) + s
    end
    "#{s[0...-precision]}.#{s[-precision..-1]}"
  end

  protected :precision, :number

end

def Fixed precision
  Fixed.subclass precision
end

Currency = Fixed(4)

