# frozen_string_literal: true

module RPrec

  # `Prec` is an operator precedence.
  class Prec

    # @param name [Symbol]
    # @param succs [Array<Symbol>]
    # @param ops [Array<Op>]
    def initialize(name, succs, ops)
      @name = name
      @succs = succs
      @ops = ops
    end

    # @dynamic name, succs, ops

    # @return [Symbol]
    attr_reader :name
    # @return [Array<Symbol>]
    attr_reader :succs
    # @return [Array<RPrec::Op>]
    attr_reader :ops

    # @api private
    # @return [Hash{String => RPrec::Op}]
    attr_reader :prefix_table
    # @api private
    # @return [Hash{String => RPrec::Op}]
    attr_reader :postfix_table

    # @api private
    # @param grammar [RPrec::Grammar]
    # @return [void]
    def setup(grammar)
      return unless @prefix_table.nil? && @postfix_table.nil?

      @prefix_table = {}
      @postfix_table = {}

      @ops.each do |op|
        case op.type
        when :prefix, :non_assoc_prefix, :closed
          if @prefix_table.include?(op.key)
            raise ArgumentError, "Conflict with the key token '#{op.key}'"
          end
          @prefix_table[op.key] = op
        when :postfix, :non_assoc_postfix, :left_assoc, :right_assoc, :non_assoc
          if @postfix_table.include?(op.key)
            raise ArgumentError, "Conflict with the key token '#{op.key}'"
          end
          @postfix_table[op.key] = op
        end
      end

      grammar.setup(@succs)

      @ops.each do |op|
        parts = op.parts.filter_map { _1.is_a?(Symbol) ? _1 : nil }
        grammar.setup(parts)
      end

      @all_prefix_keys = @prefix_table.keys
      @all_postfix_keys = @postfix_table.keys
      @prefix_keys = @prefix_table.filter { |key, op| op.type == :prefix }.keys
      @right_assoc_keys = @postfix_table.filter { |key, op| op.type == :right_assoc }.keys
      @postfix_and_left_assoc_keys = @postfix_table.filter { |key, op| op.type == :postfix || op.type == :left_assoc }.keys
    end

    # @api private
    # @param grammar [RPrec::Grammar]
    # @param stream [RPrec::Stream]
    # @return [Object, nil]
    def parse(grammar, stream)
      op = @prefix_table[stream.current.type]

      if op
        key_token = stream.current
        stream.next

        case op.type
        when :prefix
          parts = grammar.parse_parts(op.parts, stream)
          return parse_prefix_and_right_assoc(grammar, stream, [[op, [key_token, *parts]]])

        when :non_assoc_prefix
          parts = grammar.parse_parts(op.parts, stream)
          node = grammar.parse_precs(@succs, stream)
          return op.build(key_token, *parts, node)

        when :closed
          parts = grammar.parse_parts(op.parts, stream)
          return op.build(key_token, *parts)

        else raise ScriptError, 'Unreachable'
        end
      end
      stream.expected(@all_prefix_keys)

      node = grammar.parse_precs(@succs, stream)
      key_token = stream.current
      op = @postfix_table[key_token.type]
      unless op
        stream.expected(@all_postfix_keys)
        return node
      end
      stream.next

      case op.type
      when :postfix
        parts = grammar.parse_parts(op.parts, stream)
        node = op.build(node, key_token, *parts)
        return parse_postfix_and_left_assoc(grammar, stream, node)

      when :non_assoc_postfix
        parts = grammar.parse_parts(op.parts, stream)
        return op.build(node, key_token, *parts)

      when :left_assoc
        parts = grammar.parse_parts(op.parts, stream)
        right = grammar.parse_precs(@succs, stream)
        node = op.build(node, key_token, *parts, right)
        return parse_postfix_and_left_assoc(grammar, stream, node)

      when :right_assoc
        parts = grammar.parse_parts(op.parts, stream)
        return parse_prefix_and_right_assoc(grammar, stream, [[op, [node, key_token, *parts]]])

      when :non_assoc
        parts = grammar.parse_parts(op.parts, stream)
        right = grammar.parse_precs(@succs, stream)
        return op.build(node, key_token, *parts, right)

      else raise ScriptError, 'Unreachable'
      end
    end

    # @param grammar [RPrec::Grammar]
    # @param stream [RPrec::Stream]
    # @param stack [Array<Array<RPrec::Op, RPrec::Token, Object>>]
    # @return [Object]
    private def parse_prefix_and_right_assoc(grammar, stream, stack)
      continue = true
      # TODO: this untyped var seems ugly. How to fix it?
      # @type var node: untyped
      node = nil
      while continue do
        key_token = stream.current
        op = @prefix_table[key_token.type]
        while op.is_a?(Op) && op.type == :prefix
          stream.next
          parts = grammar.parse_parts(op.parts, stream)
          stack << [op, [key_token, *parts]]
          key_token = stream.current
          op = @prefix_table[key_token.type]
        end
        stream.expected(@prefix_keys)

        node = grammar.parse_precs(@succs, stream)
        key_token = stream.current
        op = @postfix_table[key_token.type]
        if op.is_a?(Op) && op.type == :right_assoc
          stream.next
          parts = grammar.parse_parts(op.parts, stream)
          stack << [op, [node, key_token, *parts]]
          continue = true
        else
          stream.expected(@right_assoc_keys)
          continue = false
        end
      end

      stack.reverse_each do |(op, args)|
        node = op.build(*args, node)
      end
      return node
    end

    # @param grammar [RPrec::Grammar]
    # @param stream [RPrec::Stream]
    # @param node [Object]
    # @return [Object]
    private def parse_postfix_and_left_assoc(grammar, stream, node)
      key_token = stream.current
      op = @postfix_table[key_token.type]
      while op.is_a?(Op) && (op.type == :postfix || op.type == :left_assoc)
        stream.next
        case op.type
        when :postfix
          parts = grammar.parse_parts(op.parts, stream)
          node = op.build(node, key_token, *parts)
        when :left_assoc
          parts = grammar.parse_parts(op.parts, stream)
          right = grammar.parse_precs(@succs, stream)
          node = op.build(node, key_token, *parts, right)
        end
        key_token = stream.current
        op = @postfix_table[key_token.type]
      end
      stream.expected(@postfix_and_left_assoc_keys)
      node
    end

    # @return [String]
    def inspect
      result = "prec #{name.inspect}"
      unless succs.empty?
        result << " => #{succs.inspect}"
      end
      unless ops.empty?
        result << " do\n"
        ops.each do |op|
          result << "  #{op.inspect}\n"
        end
        result << "end"
      end
      result
    end
  end
end
