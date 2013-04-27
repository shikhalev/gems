# encoding: utf-8

require './lib/yard-is-monkey'

Gem::Specification.new do |g|
  g.name = 'yard-is-monkey'
  g.version = Is::Monkey::YARD::VERSION
  g.summary = 'YARD plugin for use with is-monkey gem'
  g.author = 'Ivan Shikhalev'
  g.email = 'shikhalev@gmail.com'
  g.description = g.summary + '.'
  g.homepage = 'https://github.com/shikhalev/gems/'
  g.license = 'GNU LGPL'

  g.files = [ 'lib/yard-is-monkey.rb', '.yardopts' ]
  g.require_path = 'lib'
  g.required_ruby_version = '>= 1.9.2'

  g.add_dependency 'yard'
  g.add_dependency 'is-monkey'
end
