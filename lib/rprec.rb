# frozen_string_literal: true

# `RPrec` is an implementation of operator-precedence parsing.
# The operator-precedence parsing is also known as Pratt parsing.
# This implementation is extended for mixfix operators which are operators
# consists of multi parts (e.g. `... ? ... : ...` operator).
#
# ## Usage
#
# `RPrec::Grammar` is a grammar of the target language and also behaves
# its parser.
#
# We have a `RPrec::DSL` to easily build a `RPrec::Grammar` instance.
# The below is an example grammar for simple arithmetic expressions.
#
# ```
# grammar = RPrec::DSL.build do
#   prec :main => :add_sub
#
#   prec :add_sub => :mul_div do
#     left_assoc '+' do |left, op_tok, right|
#       [:add, left, right]
#     end
#     left_assoc '-' do |left, op_tok, right|
#       [:sub, left, right]
#     end
#   end
#
#   prec :mul_div => :unary do
#     left_assoc '*' do |left, op_tok, right|
#       [:mul, left, right]
#     end
#     left_assoc '/' do |left, op_tok, right|
#       [:div, left, right]
#     end
#   end
#
#   prec :unary => :atom do
#     prefix '+' do |op_tok, expr|
#       [:plus, expr]
#     end
#     prefix '-' do |op_tok, expr|
#       [:minus, expr]
#     end
#   end
#
#   prec :atom do
#     closed 'nat' do |nat_tok|
#       [:nat, nat_tok.value]
#     end
#     closed '(', :add_sub, ')' do |lpar_tok, expr, rpar_tok|
#       [:paren, expr]
#     end
#   end
# end
# ```
#
# Here, `prec` is the only available method in the `RPrec::DSL` context.
# This method is for defining a precedence and takes the argument of one of the
# following forms: `name => succs`, `name => succs`, and `name`.
# `prec name => succ` is an alias for `prec name => [succ]` and `prec name` is
# an alias for `prec name => []`. `succs` is an array of precedence names which
# have higher binding powers than this precedence's. Precedence names must be
# symbols.
#
# `prec` also can take a block to define operators belonging to this
# precedence. Operators can be defined by the following eight methods:
#
#   - `prefix key, *parts, &block`
#   - `postfix key, *parts, &block`
#   - `non_assoc_prefix key, *parts, &block`
#   - `non_assoc_postfix key, *parts, &block`
#   - `closed key, *parts, &block`
#   - `left_assoc key, *parts, &block`
#   - `right_assoc key, *parts, &block`
#   - `non_assoc key, *parts, &block`
#
# They define operators with their own name associativity. The first argument
# `key` specifies the key token that is used to determine which the operator to
# be parsed. The rest arguments are `parts`: they consist of precedence names
# or tokens, meaning that they are required after the key token. They can take
# a block, which is an action called on parsed.
#
# To parse a string using this grammar, we can use the `RPrec::Grammar#parse`
# method. This method takes a `RPrec::Stream` object. `RPrec::Stream`
# is a token stream (an array) with convenient methods for parsing. It can be
# created easily by using `RPrec::ArrayStream` class.
#
# ```
# # A stream for the source `"1 + 2 * 3"`.
# stream = RPrec::ArrayStream.new([
#   RPrec::Token.new('nat', 1),
#   RPrec::Token.new('+'),
#   RPrec::Token.new('nat', 2),
#   RPrec::Token.new('*'),
#   RPrec::Token.new('nat', 3),
# ])
#
# grammar.parse(stream)
# # => [:add, [:nat, 1], [:mul, [:nat, 2], [:nat, 3]]]
# ```
#
# ## Limitations
#
# This implementation assumes that an operator can be determined by the current
# token on parsing. If a grammar is not so, this reports the "Conflict with the
# key token ..." error.
#
# For example, the following grammar is rejected because the key token `'['`
# is conflicted.
#
# ```
# grammar = RPrec::DSL.build do
#   prec :range do
#      closed '[', :int, ',', :int, ']'
#      closed '[', :int, ',', :int, ')'
#   end
# end
# # raises "Conflict with the key token '['"
# ```
#
# ## References
#
#   - [Operator-precedence parser - Wikipedia](https://en.wikipedia.org/wiki/Operator-precedence_parser)
#   - [Parsing Mixfix Operators | Springer Link](https://link.springer.com/chapter/10.1007/978-3-642-24452-0_5)
module RPrec

  # `Error` is an error for `RPrec`.
  class Error < StandardError
  end
end

require_relative "./rprec/array_stream"
require_relative "./rprec/dsl"
require_relative "./rprec/grammar"
require_relative "./rprec/op"
require_relative "./rprec/parse_error"
require_relative "./rprec/prec"
require_relative "./rprec/regexp_lexer"
require_relative "./rprec/stream"
require_relative "./rprec/token"
require_relative "./rprec/version"
