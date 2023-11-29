# frozen_string_literal: true

require 'test_helper'

module RPrec
  class TestDSL < Minitest::Test
    def simple_expr_grammar
      RPrec::DSL.build do
        # rubocop:disable Style/HashSyntax
        prec :main => :add_sub

        prec :add_sub => :mul_div do
          left_assoc '+' do |l, _, r|
            [:add, l, r]
          end
          left_assoc '-' do |l, _, r|
            [:sub, l, r]
          end
        end

        prec :mul_div => :pow do
          left_assoc '*' do |l, _, r|
            [:mul, l, r]
          end
          left_assoc '/' do |l, _, r|
            [:div, l, r]
          end
        end

        prec :pow => :unary do
          right_assoc '**' do |l, _, r|
            [:pow, l, r]
          end
        end

        prec :unary => :atom do
          prefix '+' do |_, e|
            [:plus, e]
          end
          prefix '-' do |_, e|
            [:minus, e]
          end
        end

        prec :atom do
          closed 'INT' do |token|
            raise ScriptError, 'Unreachable' unless token.is_a?(Token)

            [:int, token.value]
          end
          closed '(', :add_sub, ')' do |_, e, _|
            [:paren, e]
          end
        end
        # rubocop:enable Style/HashSyntax
      end
    end

    def lexer
      RPrec::RegexpLexer.new(
        skip: /\s+/,
        pattern: %r{
          (?<digits>\d+)|
          (?<op>\*\*|[-+*/()])
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
    end

    def parse_simple_expr(source)
      stream = lexer.lex(source)
      simple_expr_grammar.parse(stream)
    end

    def test_simple_expr
      assert_equal [:add, [:int, 1], [:int, 2]], parse_simple_expr('1 + 2')
      assert_equal [:sub, [:int, 1], [:int, 2]], parse_simple_expr('1 - 2')
      assert_equal [:sub, [:add, [:int, 1], [:int, 2]], [:int, 3]], parse_simple_expr('1 + 2 - 3')

      assert_equal [:mul, [:int, 1], [:int, 2]], parse_simple_expr('1 * 2')
      assert_equal [:div, [:int, 1], [:int, 2]], parse_simple_expr('1 / 2')
      assert_equal [:div, [:mul, [:int, 1], [:int, 2]], [:int, 3]], parse_simple_expr('1 * 2 / 3')

      assert_equal [:add, [:mul, [:int, 1], [:int, 2]], [:int, 3]], parse_simple_expr('1 * 2 + 3')
      assert_equal [:add, [:int, 1], [:mul, [:int, 2], [:int, 3]]], parse_simple_expr('1 + 2 * 3')

      assert_equal [:pow, [:int, 1], [:int, 2]], parse_simple_expr('1 ** 2')
      assert_equal [:pow, [:int, 1], [:pow, [:int, 2], [:int, 3]]], parse_simple_expr('1 ** 2 ** 3')

      assert_equal [:add, [:plus, [:int, 1]], [:minus, [:int, 2]]], parse_simple_expr('+1 + -2')
      assert_equal [:sub, [:minus, [:int, 1]], [:plus, [:int, 2]]], parse_simple_expr('-1 - +2')

      assert_equal [:plus, [:paren, [:add, [:int, 1], [:int, 2]]]], parse_simple_expr('+(1 + 2)')
      assert_equal [:mul, [:paren, [:add, [:int, 1], [:int, 2]]], [:int, 3]], parse_simple_expr('(1 + 2) * 3')
    end
  end
end
