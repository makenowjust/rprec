# frozen_string_literal: true

module RPrec
  # `DSL` provides a DSL to construct `RPrec::Grammar` objects.
  # It is also a context of blocks of the `RPrec::DSL.build` method.
  class DSL
    # rubocop:disable Naming/BlockForwarding

    # @param main [Symbol]
    # @param block [Proc]
    # @return [RPrec::Grammar]
    def self.build(main = :main, &block)
      context = DSL.new
      context.instance_eval(&block)
      grammar = Grammar.new(main, context.precs)
      grammar.setup
      grammar
    end

    # @api private
    def initialize
      @precs = {}
    end

    # @dynamic precs

    # @api private
    # @return [Hash{Symbol => RPrec::Prec}]
    attr_reader :precs

    # @param name_and_succs [Symbol, Hash{Symbol => Symbol}, Hash{Symbol => Array<Symbol>}]
    # @param block [Proc]
    # @return [void]
    def prec(name_and_succs, &block)
      # @type var name: Symbol
      # @type var succs: Array[Symbol]
      name, succs =
        if name_and_succs.is_a?(Hash)
          name_first, succs_first = name_and_succs.first
          if name_and_succs.size != 1 || !name_first || !succs_first
            raise ArgumentError, '`prec` should be `prec name => succs` form'
          end

          [name_first, succs_first.is_a?(Array) ? succs_first : [succs_first]]
        else
          [name_and_succs, []]
        end

      raise ArgumentError, "A prec '#{name}' is already defined" if @precs.include?(name)

      @precs[name] = PrecDSL.build(name, succs, &block)
    end

    # rubocop:enable Naming/BlockForwarding

    # `PrecDSL` is a context of blocks of the `RPrec::DSL#prec` method.
    class PrecDSL
      # @api private
      # @param name [Symbol]
      # @param succs [Array<Symbol>]
      # @param block [Proc]
      # @return [RPrec::]
      def self.build(name, succs, &block)
        context = PrecDSL.new
        context.instance_eval(&block) if block
        Prec.new(name, succs, context.ops)
      end

      # @api private
      def initialize
        @ops = []
      end

      # @dynamic ops

      # @api private
      # @return [Array<RPrec::Op>]
      attr_reader :ops

      # @param key [String]
      # @param parts [Array<String, Symbol>]
      # @param build [Proc]
      # @return [void]
      def prefix(key, *parts, &build)
        @ops << Op.new(:prefix, key, parts, build)
      end

      # @param key [String]
      # @param parts [Array<String, Symbol>]
      # @param build [Proc]
      # @return [void]
      def postfix(key, *parts, &build)
        @ops << Op.new(:postfix, key, parts, build)
      end

      # @param key [String]
      # @param parts [Array<String, Symbol>]
      # @param build [Proc]
      # @return [void]
      def non_assoc_prefix(key, *parts, &build)
        @ops << Op.new(:non_assoc_prefix, key, parts, build)
      end

      # @param key [String]
      # @param parts [Array<String, Symbol>]
      # @param build [Proc]
      # @return [void]
      def non_assoc_postfix(key, *parts, &build)
        @ops << Op.new(:non_assoc_postfix, key, parts, build)
      end

      # @param key [String]
      # @param parts [Array<String, Symbol>]
      # @param build [Proc]
      # @return [void]
      def closed(key, *parts, &build)
        @ops << Op.new(:closed, key, parts, build)
      end

      # @param key [String]
      # @param parts [Array<String, Symbol>]
      # @param build [Proc]
      # @return [void]
      def left_assoc(key, *parts, &build)
        @ops << Op.new(:left_assoc, key, parts, build)
      end

      # @param key [String]
      # @param parts [Array<String, Symbol>]
      # @param build [Proc]
      # @return [void]
      def right_assoc(key, *parts, &build)
        @ops << Op.new(:right_assoc, key, parts, build)
      end

      # @param key [String]
      # @param parts [Array<String, Symbol>]
      # @param build [Proc]
      # @return [void]
      def non_assoc(key, *parts, &build)
        @ops << Op.new(:non_assoc, key, parts, build)
      end
    end
  end
end
