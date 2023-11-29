# frozen_string_literal: true

module RPrec

  # `Token` is a token.
  class Token

    # @param type [String]
    # @param value [Object]
    # @param loc [Range, nil]
    def initialize(type, value = nil, loc: nil)
      @type = type
      @value = value
      @loc = loc
    end

    # @dynamic type, value, loc

    # @return [String]
    attr_reader :type
    # @return [Object]
    attr_reader :value
    # @return [Range, nil]
    attr_reader :loc
  end
end
