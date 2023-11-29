# frozen_string_literal: true

D = Steep::Diagnostic

target :lib do
  signature 'sig'
  signature 'test/sig'

  check 'lib'
  check 'test'
  ignore 'test/test_helper.rb'

  configure_code_diagnostics(D::Ruby.default)
end
