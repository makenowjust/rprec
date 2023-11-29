# frozen_string_literal: true

module RPrec

  # `Stream` is a token stream.
  #
  # @abstract `current`, `next` and `eof?` must be implemented.
  class Stream
    def initialize
      @expected = []
    end

    # @return [RPrec::Token]
    def current
      raise ScriptError, 'Not implemented'
    end    

    # @return [void]
    def next
      @expected = []
    end

    # @return [Boolean]
    def eof?
      raise ScriptError, 'Not implemented'
    end

    # @param tokens [Array<String>]
    # @return [void]
    def expected(tokens)
      @expected += tokens
    end

    # @return [void]
    def unexpected
      token = current
      if @expected.empty?
        raise ParseError.new("Unexpected token '#{token.type}'", loc: token.loc)
      else
        expected = @expected.sort.map { |tok| "'#{tok}'" }.join(", ")
        raise ParseError.new("Expected token(s) #{expected}, but the unexpected token '#{token.type}' comes", loc: token.loc)
      end
    end
  end
end
