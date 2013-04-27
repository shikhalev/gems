# encoding: utf-8

module Is

  module Lazy

    VERSION = '0.9.1'

    # Object-placeholder for calculation.
    class Value < BasicObject

      def initialize mode, *args, &block
        case mode
        when :lambda
          @args = args
          @lambda = lambda &block
          @mode = :lambda
        when :thread
          @thread = ::Thread.start *args, &block
          @mode = :thread
        else
          @value = block.call *args
          @mode = :value
        end
      end

      # Calculate result value (or wait for thread) and return it.
      # @return [Object] calculated value.
      def value
        case @mode
        when :lambda
          @value = @lambda.call *@args
          @lambda = nil
          @args = nil
        when :thread
          @value = @thread.value
          @thread = nil
        end
        @mode = :value
        @value
      end

      # Stop the calculation and return value immediatelly.
      # If calculation was finished before, returns real value, else nil.
      # @return [Object, nil] calculated value if it's present.
      def stop
        case @mode
        when :lambda
          @args = nil
          @lambda = nil
          @value = nil
        when :thread
          if @thread.status == false
            @value = @thread.value
          else
            @thread.terminate
            @value = nil
          end
          @thread = nil
        end
        @mode = :value
        @value
      end

      # Pass all unknown method calls to value.
      def method_missing sym, *args, &block
        self.value.send sym, *args, &block
      end

      # Calculate the value and return it's logical not.
      # @return [Boolean] true if value is nil or false, false elsewhere.
      def !
        ! self.value
      end

      # Calculate and return the value.
      # This is a shortest expression with value.
      # @return [Object] calculated value.
      def +@
        self.value
      end

      # Calculate value and compare it with other object.
      # @param other [Object]
      # @return [Boolean]
      def == other
        self.value == other
      end

      # Calculate value and compare it with other object.
      # @param other [Object]
      # @return [Boolean]
      def != other
        self.value != other
      end

      # Calculate value and compare it with other object.
      # @param other [Object]
      # @return [Boolean]
      def equal? other
        self.value.equal? other
      end

      # Calculate value and convert it to boolean.
      # @return [Boolean] false if value is false or nil, true elsewhere.
      def true?
        ! ! self.value
      end

      alias to_b true?

      # Used by interpreter for implicit convertion to String.
      # @return [String, nil]
      def to_str
        if self.value.respond_to? :to_str
          self.value.to_str
        else
          self.value.to_s
        end
      end

      # Used by interpreter for implicit convertion to Array.
      # @return [Array, nil]
      def to_ary
        self.value.to_ary
      end

      # Used by interpreter for implicit convertion to Proc.
      # @return [Proc, nil]
      def to_proc
        self.value.to_proc
      end

      # Used by interpreter for implicit convertion to Regexp.
      # @return [Regexp, nil]
      def to_regexp
        self.value.to_regexp
      end

      # Used by interpreter for implicit convertion to Symbol.
      # @return [Symbol, nil]
      def to_sym
        self.value.to_sym
      end

    end

    # Create lazy calculated object.
    # @yield [*args] Calculation of value.
    # @return [Value]
    def lazy *args, &block
      Value.new :lambda, *args, &block
    end

    # Create thread calculated object.
    # @yield [*args] Calculation of value.
    # @return [Value]
    def go *args, &block
      Value.new :thread, *args, &block
    end

    module_function :lazy, :go

  end

end
