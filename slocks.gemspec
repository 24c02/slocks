# frozen_string_literal: true

require_relative "lib/slocks/version"

Gem::Specification.new do |spec|
  spec.name = "slocks"
  spec.version = Slocks::VERSION
  spec.authors = ["24c02"]
  spec.email = ["slocks@noras.email"]

  spec.summary = "Rails template handler for Slack Block Kit"
  spec.description = "A Rails template handler that provides a clean DSL for building Slack Block Kit blocks and modals"
  spec.homepage = "https://github.com/24c02/slocks"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/24c02/slocks"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "actionview", ">= 6.0"
  spec.add_dependency "activesupport", ">= 6.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
