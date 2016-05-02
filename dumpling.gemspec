# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dumpling/version'

Gem::Specification.new do |spec|
  spec.name = 'dumpling'
  spec.version = Dumpling::Version::STRING
  spec.author = 'Anton Kuzmenko'
  spec.email = 'antonkuzmenko.dev@gmail.com'
  spec.homepage = 'https://github.com/antonkuzmenko/dumpling'
  spec.license = 'MIT'

  spec.summary = 'Dumpling is an unobtrusive Dependency Injection Container'

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\Aspec/}) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.2.2'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 11.1'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.39.0'
  spec.add_development_dependency 'simplecov', '~> 0.11'
end
