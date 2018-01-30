# frozen_string_literal: true

require_relative 'lib/guard/sass/version'

Gem::Specification.new do |s|
  s.name        = 'guard-sass'
  s.version     = Guard::SassVersion::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Joshua Hawxwell']
  s.email       = ['m@hawx.me']
  s.homepage    = 'http://rubygems.org/gems/guard-sass'
  s.summary     = 'Guard gem for Sass'
  s.description = 'Guard::Sass automatically rebuilds sass (like sass --watch)'

  s.required_rubygems_version = '>= 1.3.6'
  s.rubyforge_project         = 'guard-sass'

  s.add_dependency 'guard',        '~> 2.14'
  s.add_dependency 'guard-compat', '~> 1.2'
  s.add_dependency 'sass',         '~> 3.5'

  s.add_development_dependency 'bundler',     '~> 1.16'
  s.add_development_dependency 'guard-rspec', '~> 4.7'
  s.add_development_dependency 'rspec',       '~> 3.7'
  s.add_development_dependency 'rubocop',     '~> 0.52'

  s.files        = Dir.glob('{lib}/**/*') + %w[LICENSE README.md]
  s.require_path = 'lib'
end
