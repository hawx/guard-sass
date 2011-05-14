# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'guard/sass'

Gem::Specification.new do |s|
  s.name        = 'guard-sass'
  s.version     = Guard::Sass::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Joshua Hawxwell']
  s.email       = ['m@hawx.me']
  s.homepage    = 'http://rubygems.org/gems/guard-sass'
  s.summary     = 'Guard gem for Sass'
  s.description = 'Guard::Sass automatically rebuilds sass (like sass --watch)'
  
  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project         = 'guard-sass'
  
  s.add_dependency 'guard',   '>= 0.2.1'
  s.add_dependency 'haml',    '~> 3.0.0'
  
  s.add_development_dependency 'bundler', '~> 1.0.2'
  s.add_development_dependency 'rspec',   '> 2.0.0.rc'
  
  s.files        = Dir.glob('{lib}/**/*') + %w[LICENSE README.md]
  s.require_path = 'lib'
end
