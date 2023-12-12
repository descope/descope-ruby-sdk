# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'descope/version'

Gem::Specification.new do |s|
  s.name        = 'descope'
  s.version     = Descope::VERSION
  s.authors     = ['Descope']
  s.email       = ['support@descope.com']
  s.homepage    = 'https://github.com/descope/ruby-sdk'
  s.summary     = 'Descope API Client'
  s.description = 'Ruby API Client for Descope API https://descope.com'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_runtime_dependency 'rest-client', '~> 2.1'
  s.add_runtime_dependency 'jwt', '~> 2.7'
  s.add_runtime_dependency 'zache', '~> 0.12'
  s.add_runtime_dependency 'addressable', '~> 2.8'
  s.add_runtime_dependency 'retryable', '~> 3.0'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'fuubar', '~> 2.0'
  s.add_development_dependency 'rspec', '~> 3.11'
  s.add_development_dependency 'simplecov', '~> 0.9'
  s.add_development_dependency 'faker', '~> 2.0'
  s.license = 'MIT'
end