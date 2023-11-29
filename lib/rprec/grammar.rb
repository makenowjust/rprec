# frozen_string_literal: true

module RPrec
  # `Grammar` is a grammar defined by operator precedences.
  class Grammar
    # @param main [Symbol]
    # @param precs [Hash{Symbol => RPrec::Prec}]
    def initialize(main, precs)
      @main = main
      @precs = precs
    end

    # @param name [Symbol]
    # @return [RPrec::Prec]
    def [](name)
      prec = @precs[name]
      raise KeyError, "A prec '#{name}' is undefined" unless prec

      prec
    end

    # @api private
    # @param names [Array<Symbol>]
    # @return [void]
    def setup(names = [@main])
      names.each do |name|
        prec = self[name]
        prec.setup(self)
      end
    end

    # @param stream [RPrec::Stream]
    # @param check_eof [Boolean]
    # @return [Object]
    def parse(stream, check_eof: true)
      result = parse_prec(@main, stream)
      stream.unexpected unless result

      if check_eof
        stream.expected(['EOF'])
        stream.unexpected unless stream.eof?
      end

      result
    end

    # @api private
    # @param names [Array<Symbol>]
    # @param stream [RPrec::Stream]
    # @return [Object]
    def parse_precs(names, stream)
      names.each do |name|
        result = parse_prec(name, stream)
        return result if result
      end
      stream.unexpected
    end

    # @api private
    # @param name [Symbol]
    # @param stream [RPrec::Stream]
    # @return [Object, nil]
    def parse_prec(name, stream)
      prec = self[name]
      prec.parse(self, stream)
    end

    # @api private
    # @param parts [Array<String, Symbol>]
    # @param stream [RPrec::Stream]
    # @return [Array<RPrec::Token, Object>]
    def parse_parts(parts, stream)
      parts.map do |part|
        if part.is_a?(Symbol)
          result = parse_prec(part, stream)
          stream.unexpected unless result
          result
        else
          token = stream.current
          unless token.type == part
            stream.expected([part])
            stream.unexpected
          end
          stream.next
          token
        end
      end
    end

    # @return [String]
    def inspect
      result = "DSL.build #{@main.inspect} do\n"
      @precs.each do |(_, prec)|
        prec.inspect.lines(chomp: true).each do |line|
          result << "  #{line}\n"
        end
      end
      result << 'end'
      result
    end
  end
end
