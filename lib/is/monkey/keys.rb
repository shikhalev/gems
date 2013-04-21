# encoding : utf-8

class Symbol

  # @return [self]
  def to_key
    self
  end

  # @return [String]
  def to_name
    to_s.gsub '_', '-'
  end

end

class String

  # @return [Symbol]
  def to_key
    gsub('-', '_').intern
  end

  # @return [self]
  def to_name
    self
  end

end

class Integer

  # @return [self]
  def to_key
    self
  end

  # @return [self]
  def to_name
    self
  end

end
