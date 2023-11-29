# frozen_string_literal: true

module RPrec
  # `ParseError` is an error on parsing.
  class ParseError < Error
    # @param message [String]
    # @param loc [Range, nil]
    def initialize(message, loc: nil)
      full_message = loc ? "#{message} at #{loc}" : message
      @loc = loc
      super(full_message)
    end

    # @dynamic loc

    # @return [Range, nil]
    attr_reader :loc
  end
end
