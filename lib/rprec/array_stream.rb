# frozen_string_literal: true

require_relative 'stream'

module RPrec
  # `ArrayStream` is a simple implementation of `RPrec::Stream` with an array.
  class ArrayStream < Stream
    # @param tokens [Array<RPrec::Token>]
    def initialize(tokens)
      super()
      @tokens = tokens
      @index = 0
    end

    # @return [RPrec::Token]
    def current
      return Token.new('EOF') if eof?

      @tokens[@index]
    end

    # @return [void]
    def next
      super
      @index += 1
    end

    # @return [Boolean]
    def eof?
      @index >= @tokens.size
    end
  end
end
