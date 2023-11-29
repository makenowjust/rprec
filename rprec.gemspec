# frozen_string_literal: true

require_relative "lib/rprec/version"

Gem::Specification.new do |spec|
  spec.name = "rprec"
  spec.version = RPrec::VERSION
  spec.authors = ["TSUYUSATO Kitsune"]
  spec.email = ["make.just.on@gmail.com"]

  spec.summary = "Operator-precedence parsing implementation in Ruby"
  spec.description = <<~DESCRIPTION
    `RPrec` is an implementation of operator-precedence parsing.
    The operator-precedence parsing is also known as Pratt parsing.
    This implementation is extended for mixfix operators which are operators consists of multi parts (e.g. `... ? ... : ...` operator).
  DESCRIPTION
  spec.homepage = "https://github.com/makenowjust/rprec"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/makenowjust/rprec.git"
  spec.metadata["changelog_uri"] = "https://github.com/makenowjust/rprec/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
