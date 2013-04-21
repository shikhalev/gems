# encoding: utf-8

require 'yard'

module Is

  module MonkeyYARD

    VERSION = '0.1.0'

    class PropertyHandler < YARD::Handlers::Ruby::AttributeHandler

      handles method_call(:property)
      namespace_only

      def process
        return if statement.type == :var_ref || statement.type == :vcall
        params = statement.parameters(false).dup
        cls = nil
        grp = 'Properties'
        while params[-1].type == :list
          arg = params.pop.source.scan(/(?::class\s*=>|class:)\s*([\w:]+)/)[0]
          cls = arg[0] if arg
        end
        validated_attribute_names(params).each do |name|
          namespace.attributes[scope][name] ||= SymbolHash[:read => nil,
                                                           :write => nil]
          { :read => name, :write => "#{name}=" }.each do |type, meth|
            o = MethodObject.new namespace, meth, scope
            case type
            when :read
              # par = [['*values']]
              sgn = "def #{name} *values"
              src = "#{sgn}\n  @#{name} << *values if ! values.empty? # abstract pseudocode\n  @#{name}\nend"
            when :write
              par = [['value']]
              sgn = "def @{name}= value"
              src = "#{sgn}\n  @#{name} = value # abstract pseudocode\nend"
              doc = "Set new value to \"#{name}\" property."
              if cls
                doc += "\n@param [#{cls}] value"
              end
            end
            o.parameters = par if par
            o.signature = sgn
            o.source = src
            register(o)
            o.docstring = doc if o.docstring.blank?(false)
            o.docstring += "\n@return [#{cls}]" if cls
            o.group = (scope == :class) ? "Class #{grp}" : "Instance #{grp}"
            namespace.attributes[scope][name][type] = o
          end
        end
      end

    end

  end

end