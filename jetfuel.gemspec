# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'jetfuel/version'
require 'date'

Gem::Specification.new do |s|
  s.required_ruby_version = ">= #{Jetfuel::RUBY_VERSION}"
  s.authors = ['FlyoverWorks']
  s.date = Date.today.strftime('%Y-%m-%d')

  s.description = <<-HERE
Jetfuel is a base Rails project that you can upgrade. It is used by
FlyoverWorks to get a jump start on a working app. Use Jetfuel if you're in a
rush to build something amazing; don't use it if you like missing deadlines.
  HERE

  s.email = 'david@flyoverworks.com'
  s.executables = ['jetfuel']
  s.extra_rdoc_files = %w[README.md LICENSE]
  s.files = `git ls-files`.split("\n")
  s.homepage = 'http://github.com/FlyoverWorks/jetfuel'
  s.license = 'MIT'
  s.name = 'jetfuel'
  s.rdoc_options = ['--charset=UTF-8']
  s.require_paths = ['lib']
  s.summary = "Generate a Rails app using FlyoverWorks' best practices."
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.version = Jetfuel::VERSION

  s.add_dependency 'bundler', '~> 1.3'
  s.add_dependency 'rails', Jetfuel::RAILS_VERSION

  s.add_development_dependency 'aruba', '~> 0.5'
  s.add_development_dependency 'cucumber', '~> 1.2'
  s.add_development_dependency 'rspec', '~> 2.0'
  s.add_development_dependency 'capybara', '~> 2.2', '>= 2.2.0'
end
