# encoding: utf-8

require 'is/monkey/sandbox'

class Module

  # @return [String]
  def basename
    name.split('::')[-1]
  end

  # @return [Module]
  def namespace
    begin
      nm = name
      if (i = nm.rindex '::')
        ns = sandbox { eval nm[0...i] }
        return ns
      end
    rescue
    end
    return nil
  end

  # @param [Module] other
  # @return [Boolean]
  def in? other
    ns = self
    while (ns = ns.namespace)
      return true if ns == other
    end
    return false
  end

  # @return [Boolean]
  def global?
    ! namespace
  end

end
