# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gt_ruby_sdk/version'

Gem::Specification.new do |spec|
  spec.name          = 'gt_ruby_sdk'
  spec.version       = GtRubySdk::VERSION
  spec.authors       = ['LcpMarvel']
  spec.email         = ['lcpmarvel@gmail.com']

  spec.summary       = 'GtWeb Ruby SDK'
  spec.description   = 'GtWeb Ruby SDK'
  spec.homepage      = 'https://github.com/LcpMarvel/gt-ruby-sdk'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'

  spec.add_dependency 'faraday'
  spec.add_dependency 'activesupport'
end
