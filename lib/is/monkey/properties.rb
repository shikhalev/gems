# encoding: utf-8

class Module

  # @overload property *args, opts = {}
  #   @param [Array<Symbol>] args
  #   @param [Hash] opts
  #   @option opts [Proc] :init
  #   @option opts [Object] :default
  #   @option opts [#===] :validator
  #   @option opts [Class] :class
  #   @option opts [true] :null
  #   @yield [value]
  #   @return [void]
  def property *args, &block
    @properties ||= {}
    if Hash === args[-1]
      opts = args.pop
    else
      opts = {}
    end
    init = opts[:init]
    default = opts[:default]
    validator = opts[:validator]
    valclass = opts[:class]
    valnull = opts[:null]
    args.each do |a|
      getter = a.intern
      variable = "@#{getter}".intern
      setter = "#{getter}=".intern

      get_proc = define_method getter do |*aa|
        if ! instance_variable_defined?(variable)
          instance_variable_set variable,
              singleton_class.properties[getter].default(self)
        end
        value = instance_variable_get variable
        if aa.size != 0
          if value.respond_to? :merge
            aa.each do |a|
              value = value.merge a
            end
          elsif aa.size == 1
            value = aa[0]
          else
            value = aa
          end
          send setter, value
        end
        instance_variable_get variable
      end

      if block_given?
        set_proc = define_method setter, &block
      else

        set_proc = define_method setter do |value|
          if validator && !(validator === value || valnull && value == nil)
            raise 'Invalid property value!'
          elsif valclass && !(valclass === value || valnull && value == nil)
            raise 'Invalid property value class!'
          end
          instance_variable_set variable, value
        end

      end

      @properties[getter] = Is::Property.new self, getter,
          opts.merge(:getter => get_proc, :setter => set_proc)
    end
  end

  # @return [Hash{Symbol => Is::Property}]
  def properties
    result = @properties || {}
    ancestors.each do |mod|
      result = mod.properties.merge result if mod != self
    end
    if self < Class && superclass
      result = superclass.properties.merge result
    end
    result
  end

  private :property

end

class Object

  # @param [Array<Symbol>] args
  # @return [Hash{Symbol => Object}]
  def property_values *args
    result = {}
    if args.size != 0
      args.each do |arg|
        prop = arg.intern
        result[prop] = send prop
      end
    else
      singleton_class.properties.each do |prop, _|
        result[prop] = send prop
      end
    end
    result
  end

end

module Is

  class Property

    # @return [Symbol]
    attr_reader :name

    # @return [Proc]
    attr_reader :getter

    # @return [Proc]
    attr_reader :setter

    # @return [Hash]
    attr_reader :options

    # @return [Module]
    attr_reader :owner

    def getter
      @opts[:getter]
    end

    def setter
      @opts[:setter]
    end

    def options
      @opts
    end

    # @param [Module] owner
    # @param [Symbol] name
    # @param [Hash] opts
    def initialize owner, name, opts = {}
      @owner = owner
      @name = name.intern
      @opts = opts
    end

    # @param [Object] obj
    # @return [Object, nil]
    def default obj
      if Class === obj && obj.superclass && obj.superclass.respond_to?(@name)
        v = obj.superclass.send @name
      else
        v = nil
      end
      if v == nil
        if @opts.has_key? :init
          v = @opts[:init].call obj
        elsif @opts.has_key? :default
          v = @opts[:default]
        elsif @opts.has_key? :class
          v = @opts[:class].new
        end
      end
      v
    end

    module Validators

      class OR

        # @param [Array<#===>] args
        def initialize *args
          @args = args
        end

        # @param [Object] value
        # @return [Boolean]
        def === value
          @args.each do |v|
            if v === value
              return true
            end
          end
          return false
        end

      end

      class AND

        # @param [Array<#===>] args
        def initialize *args
          @args = args
        end

        # @param [Object] value
        # @return [Boolean]
        def === value
          @args.each do |v|
            if !(v === value)
              return false
            end
          end
          return true
        end

      end

      class NOT

        # @param [#===] arg
        def initialize arg
          @arg = arg
        end

        # @param [Object] value
        # @return [Boolean]
        def === value
          !(@arg === value)
        end

      end

      class ANY < OR
      end

      class ALL < AND
      end

      class ONE

        # @param [Array<#===>] args
        def initialize *args
          @or = OR.new *args
          @and = AND.new *args
        end

        # @param [Object] value
        # @return [Boolean]
        def === value
          @or === value && !(@and === value)
        end

      end

      # @param [Array<#===>] args
      # @return [OR]
      def v_or *args
        OR.new *args
      end

      # @param [Array<#===>] args
      # @return [AND]
      def v_and *args
        AND.new *args
      end

      # @param [#===] arg
      # @return [NOT]
      def v_not arg
        NOT.new arg
      end

      # @param [Array<#===>] args
      # @return [ANY]
      def v_any *args
        ANY.new *args
      end

      # @param [Array<#===>] args
      # @return [ALL]
      def v_all *args
        ALL.new *args
      end

      # @param [Array<#===>] args
      # @return [ONE]
      def v_one *args
        ONE.new *args
      end

      module_function :v_or, :v_and, :v_not, :v_any, :v_all, :v_one

    end

  end

end
