# encoding : utf-8

class Symbol

  def to_key
    self
  end

  def to_name
    to_s.gsub '_', '-'
  end

end

class String

  def to_key
    gsub('-', '_').intern
  end

  def to_name
    self
  end

end

class Integer

  def to_key
    self
  end

  def to_name
    self
  end

end
