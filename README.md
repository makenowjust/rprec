# RPrec

[![Gem](https://img.shields.io/gem/v/rprec?style=for-the-badge&logo=rubygems&color=%23E9573F)](https://rubygems.org/gems/rprec)
[![RubyDoc.info](https://img.shields.io/badge/RUBYDOC-HERE-CC342D?style=for-the-badge&logo=ruby)](https://rubydoc.info/github/makenowjust/rprec/main/RPrec)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/makenowjust/rprec/main.yml?style=for-the-badge&logo=github)](https://github.com/makenowjust/rprec/actions/workflows/main.yml)


> Operator-precedence parsing implementation in Ruby

## Usage

Below is a parser for the grammar of simple expressions:

```ruby
grammar = RPrec::DSL.build do
  prec :main => :add_sub

  prec :add_sub => :mul_div do
    left_assoc '+' do |left, op_tok, right|
      [:add, left, right]
    end
    left_assoc '-' do |left, op_tok, right|
      [:sub, left, right]
    end
  end

  prec :mul_div => :unary do
    left_assoc '*' do |left, op_tok, right|
      [:mul, left, right]
    end
    left_assoc '/' do |left, op_tok, right|
      [:div, left, right]
    end
  end

  prec :unary => :atom do
    prefix '+' do |op_tok, expr|
      [:plus, expr]
    end
    prefix '-' do |op_tok, expr|
      [:minus, expr]
    end
  end

  prec :atom do
    closed 'INT' do |int_tok|
      [:nat, int_tok.value]
    end
    closed '(', :add_sub, ')' do |lpar_tok, expr, rpar_tok|
      [:paren, expr]
    end
  end
end
```

This can be used via `RegexpLexer`:

```ruby
lexer = RPrec::RegexpLexer.new(
  skip: /\s+/,
  pattern: %r{
    (?<digits>\d+)|
    (?<op>[-+*/()])
  }x
) do |match|
  if (value = match[:digits])
    ['INT', value.to_i]
  elsif (op = match[:op])
    op
  else
    raise ScriptError, 'Unreachable'
  end
end

grammar.parse(lexer.lex('1 + 2 * 3'))
# => [:add, [:int, 1], [:mul, [:int, 2], [:int, 3]]]
```

For the detailed information, please see [the documentation](https://rubydoc.info/github/makenowjust/rprec/main/RPrec).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/makenowjust/rprec. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/makenowjust/rprec/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rprec project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/makenowjust/rprec/blob/main/CODE_OF_CONDUCT.md).
