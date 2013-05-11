# encoding: utf-8

class Fixed < Numeric

  VERSION = '0.2.0'

  class << self

    # @return [Integer]
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

    # @param [Integer] precision
    # @return [Class]
    def subclass precision
      @@classes ||= []
      if ! @@classes[precision]
        @@classes[precision] = Class.new(Fixed)
        @@classes[precision].precision = precision
      end
      @@classes[precision]
    end

    # @param [Numeric] value
    # @param [Integer] precision
    # @return [Fixed]
    def number value, precision
      subclass(precision).new(value)
    end

    # @param [Numeric] value
    # @return [Fixed]
    def [] value
      self.new value
    end

    # @return [String]
    def to_s
      name || "Fixed(#{@precision})"
    end

  end

  # @return [Integer]
  attr_reader :precision

  # @return [Integer]
  attr_reader :number

  def precision
    self.class.precision
  end

  # @param [Numeric] number
  # @param [Integer] shift
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

  # @return [Fixed]
  def +@
    self
  end

  # @return [Fixed]
  def -@
    self.class.new -@number, precision
  end

  # @param [Numeric] other
  # @return [Fixed]
  def + other
    other = self.class.new other
    self.class.new @number + other.number, precision
  end

  # @param [Numeric] other
  # @return [Fixed]
  def - other
    self + (-other)
  end

  # @param [Numeric] other
  # @return [Fixed]
  def * other
    case other
    when Fixed
      self.class.new @number * other.number, precision + other.precision
    when Integer
      self.class.new @number * other, precision
    else
      self.class.new (Float(other) * @number).round, precision
    end
  end

  # @param [Numeric] other
  # @return [Fixed]
  def / other
    # /
    case other
    when Fixed
      n = @number * 10 ** other.precision
      nn = n.divmod other.number
      self.class.new nn[0] + (nn[1] < 5 && 0 || 1), precision
    when Integer
      nn = @number.divmod other
      self.class.new nn[0] + (nn[1] < 5 && 0 || 1) / other.number, precision
    else
      self.class.new Float(@number) / Float(other), precision
    end
  end

  # @param [Numeric] other
  # @return [Fixed]
  def ** other
    case other
    when Integer
      n = self.class.new 1
      if other > 0
        other.times { n = n * self }
      elsif other < 0
        other.times { n = n / self }
      end
      n
    when Fixed
      if other.integer?
        self ** other.to_i
      else
        self ** other.to_f
      end
    else
      self.class.new self.to_f ** Float(other)
    end
  end

  def integer?
    @number.divmod(10 ** precision)[1] == 0
  end

  # @return [Integer]
  def to_i
    @number.divmod(10 ** precision)[0]
  end

  # @return [Float]
  def to_f
    Float(@number) / Float(10 ** precision)
  end

  # @return [String]
  def to_s
    s = @number.to_s
    l = s.length
    if l <= precision
      s = '0' * (precision - l + 1) + s
    end
    "#{s[0...-precision]}.#{s[-precision..-1]}"
  end

  def <=> other
    if precision >= other.precision
      @number <=> self.class.new(other).number
    else
      other.class.new(self).number <=> other.number
    end
  end

  def abs
    self.class.new(@number.abs, precision)
  end

  def abs2
    self * self
  end

  def coerce other
    if Integer === other
      [self.class.new(other), self]
    else
      super other
    end
  end

  protected :precision, :number

end

# @param [Integer] precision
# @return [Class]
def Fixed precision
  Fixed.subclass precision
end

Currency = Fixed(4)

