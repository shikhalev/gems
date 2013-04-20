# encoding: utf-8

require 'optparse'

module Is

  class Command

    VERSION = '0.9.2'

    module Mixin

      @@messages = {
        :commands => 'Commands',
        :actions => 'Actions',
        :aliases => 'Aliases',
        :commons => 'Common options',
        :options => 'Options'
      }

      class << self

        # @param [Hash] values
        # @return [Hash]
        def messages values = {}
          @@messages.merge! values
        end

      end

      # @return [Symbol, nil]
      attr_reader :name

      # @return [Array<String>, nil]
      attr_reader :description

      # @param [Symbol, String] name
      # @param [Array<String>] description
      # @yield [*args]
      # @return [Command]
      def command name, *description, &block
        @actions ||= {}
        @actions[name.intern] = Command.new self, name, *description, &block
      end

      # @param [Symbol, String, nil] name
      # @param [Array<String>] description
      # @yield [*args]
      # @return [Hash, Proc]
      def action name = nil, *description, &block
        @actions ||= {}
        if name
          @actions[name.intern] = {
            :name => name.intern,
            :description => description,
            :block => block
          }
        else
          @block = block
        end
      end

      # @param [Symbol, String] name
      # @return [Command, Hash, Array, String, Symbol, nil]
      def [] name
        @actions[name.intern]
      end

      # @param [Hash, Array<Symbol>, nil] args
      # @yield [name, action]
      # @return [void]
      def each *args, &block
        if args.size == 0
          c = a = s = true
        elsif Hash === args[0]
          h = args[0]
          c = h[:command]
          a = h[:action]
          s = h[:synonym] || h[:alias]
        else
          c = args.include? :command
          a = args.include? :action
          s = args.include?(:synonym) || args.include?(:alias)
        end
        @actions.select do |k, v|
          (c && Command === v) || (a && Hash === v) ||
            (s && (Array === v || String === v || Symbol === v))
        end.each &block
      end

      # @yield [*args]
      # @return [Proc]
      def default &block
        action &block
      end

      # @param [Symbol, String] name
      # @param [Array<String>, String, Symbol] source
      # @return [Array<String>, String, Symbol]
      def synonym name, source
        @actions ||= {}
        @actions[name.intern] = source
      end

      # @return [Array<Hash>]
      def commons
        @commons ||= []
        if @up.respond_to? :commons
          @up.commons + @commons
        else
          @commons
        end
      end

      # @param [Array<String, Class>] defs
      # @yield [value]
      # @return [Hash]
      def key *defs, &block
        @keys ||= []
        @commons ||= []
        if Hash === defs[-1]
          opts = defs.pop
        else
          opts = {}
        end
        k = { :defs => defs, :block => block }
        if opts[:common]
          @commons << k
        else
          @keys << k
        end
        k
      end

      # @param [Array<String>] args
      # @return [Array<String>]
      def parse *args
        @options ||= {}
        @keys ||= []
        @commons ||= []
        context = self
        opts = OptionParser.new do |o|
          (commons + @keys).each do |k|
            defs = k[:defs]
            block = proc do |value|
              context.instance_exec value, &k[:block]
            end
            o.on *defs, &block
          end
        end
        opts.order args
      end

      # @param [Array<String>] args
      # @return [Object, nil]
      def process *args
        @actions ||= {}
        if Hash === args[-1]
          @options = args.pop
        else
          @options = {}
        end
        args = parse *args
        if args[0]
          a = @actions[args[0].intern]
          case a
          when Command
            args.shift
            return a.process *args, @options
          when Hash
            args.shift
            args = parse *args
            return instance_exec *args, &a[:block]
          when Array
            args.shift
            return process *a, *args, @options
          when String, Symbol
            args.shift
            return process a.to_s, *args, @options
          end
        end
        if @block
          return instance_exec *args, &@block
        else
          raise 'Invalid command line.'
        end
      end

      # @return [String, nil]
      def fullname
        if @up && @up.respond_to?(:fullname)
          @up.fullname + ' ' + @name.to_s
        else
          @name.to_s
        end
      end

      # @param [Hash] opts
      # @option opts [Boolean, String, :auto] :highlight
      # @option opts [Boolean, String, :auto] :color
      # @option opts [String] :marker
      # @return [String]
      def help opts = {}
        h = opts[:highlight] || opts[:color]
        hl = opts[:marker] || "\e[1m"
        hr = ''
        case h
        when true, :true, :TRUE, :yes, :YES
          hr = "\e[0m;"
        when false, :false, :FALSE, :no, :NO
          hl = ''
        when nil, :auto, :AUTO
          if $stdout.stat.chardev?
            hr = "\e[0m"
          else
            hl = ''
          end
        else
          hl = h
          hr = "\e[0m"
        end
        cc = {}
        aa = {}
        ss = {}
        @actions.each do |k, v|
          case v
          when Command
            cc[k] = v
          when Hash
            aa[k] = v
          else
            ss[k] = v
          end
        end
        mm = opts[:nocommons] ? @commons : commons or []
        kk = @keys || []
        result = ''
        result << "#{hl}#{fullname}#{hr}\n"
        result << "\t#{@description.join("\n\t")}\n"
        result << "\n"
        if ! cc.empty?
          result << "#{hl}#{@@messages[:commands]}:#{hr}\n"
          cc.each do |k, v|
            result << "\t#{k}\n"
          end
          result << "\n"
        end
        if ! aa.empty?
          result << "#{hl}#{@@messages[:actions]}:#{hr}\n"
          aa.each do |k, v|
            result << "\t#{k}\n"
          end
          result << "\n"
        end
        if ! ss.empty?
          result << "#{hl}#{@@messages[:aliases]}:#{hr}\n"
          aa.each do |k, v|
            if Array === v
              value = v.join ' '
            else
              value = v.to_s
            end
            result << "\t#{k} = #{value}\n"
          end
          result << "\n"
        end
        if ! mm.empty?
          result << "#{hl}#{@@messages[:commons]}:#{hr}\n"
          o = OptionParser.new
          mm.each do |k|
            o.on *k[:defs]
          end
          result << "#{o.summarize.join('')}\n"
          #result << "\n"
        end
        if ! kk.empty?
          result << "#{hl}#{@@messages[:options]}:#{hr}\n"
          o = OptionParser.new
          kk.each do |k|
            o.on *k[:defs]
          end
          result << "#{o.summarize.join('')}\n"
          #result << "\n"
        end
        aa.each do |k, v|
          result << "#{hl}#{fullname} #{k}#{hr}\n"
          result << "\t#{v[:description].join("\n\t")}\n"
          result << "\n"
        end
        cc.each do |k, v|
          result << v.help(:nocommons => true)
        end
        # result << "\n"
        GC.start
        result
      end

      # @return [Proc]
      def to_proc
        method(:process).to_proc
      end

      private :command, :action, :default, :synonym, :key, :parse
      protected :commons

    end

    class Application

      include Mixin

      def initialize name = nil, *description, &block
        if name
          @name = name.intern
        end
        @description = description
        instance_eval &block
      end

      # @return [Object, nil]
      def run
        process *ARGV
      end

    end

    class << self

      # @param [Symbol, String, nil] name
      # @param [Array<String>] description
      # @yield
      # @return [Object, nil]
      def runapp name = nil, *description, &block
        app = Command::Application.new name, *description, &block
        app.run
      end

    end

    include Mixin

    def initialize up, name, *description, &block
      @up = up
      @name = name.intern if name
      @description = description
      instance_eval &block
    end

  end

end
