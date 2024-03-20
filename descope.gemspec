# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'descope/version'
version = Descope::VERSION

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = "descope"
  s.version     = version
  s.summary     = "Descope Ruby API Client"
  s.description = "Ruby API Client for Descope API https://descope.com"

  s.required_ruby_version     = ">= 3.3.0"
  s.required_rubygems_version = ">= 3.5"

  s.author      = "Descope Inc."
  s.email       = "support@descope.com"
  s.homepage    = "https://github.com/descope/descope-ruby-sdk"

  s.license = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.metadata = {
    "bug_tracker_uri"   => "https://github.com/descope/descope-ruby-sdk/issues",
    "changelog_uri"     => "https://github.com/descope/descope-ruby-sdk/releases/tag/#{version}",
    "documentation_uri" => "https://docs.descope.com",
    "source_code_uri" => "https://github.com/descope/descope-ruby-sdk/tree/#{version}",
  }

  s.add_runtime_dependency 'addressable', '~> 2.8'
  s.add_runtime_dependency 'jwt', '~> 2.7'
  s.add_runtime_dependency 'rest-client', '~> 2.1'
  s.add_runtime_dependency 'retryable', '~> 3.0'
  s.add_runtime_dependency 'zache', '~> 0.12'
end
