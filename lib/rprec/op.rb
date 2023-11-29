# frozen_string_literal: true

module RPrec
  # `Op` is an operator.
  class Op
    # @param type [:prefix, :postfix, :non_assoc_prefix, :non_assoc_postfix, :closed, :left_assoc, :right_assoc, :non_assoc]
    # @param key [String]
    # @param parts [Array<String, Symbol>]
    # @param build [Proc]
    def initialize(type, key, parts, build)
      @type = type
      @key = key
      @parts = parts
      @build = build
    end

    # @dynamic type, key, parts

    # @return [:prefix, :postfix, :non_assoc_prefix, :non_assoc_postfix, :closed, :left_assoc, :right_assoc, :non_assoc]
    attr_reader :type
    # @return [String]
    attr_reader :key
    # @return [Array<String, Symbol>]
    attr_reader :parts

    # rubocop:disable Style/ArgumentsForwarding

    # @param args [Array<RPrec::Token, Object>]
    # @return [Object]
    def build(*args)
      @build.call(*args)
    end

    # rubocop:enable Style/ArgumentsForwarding

    # @return [String]
    def inspect
      "#{type} #{([key] + parts).map(&:inspect).join(', ')}"
    end
  end
end
