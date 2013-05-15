# encoding: utf-8

require 'is/build'
require './lib/is/monkey'

Gem::Specification.new do |g|
  g.name = 'is-monkey'
  g.version = Is::Monkey::VERSION
  g.summary = 'The set of monkey-patching'
  g.author = 'Ivan Shikhalev'
  g.email = 'shikhalev@gmail.com'
  g.description = g.summary + '.'
  g.homepage = 'https://github.com/shikhalev/gems/'
  g.license = 'GNU LGPL'

  g.files = Dir['lib/is/monkey/*.rb'] + [ '.yardopts' ]

  g.mkbuild

  g.require_path = 'lib'
  g.required_ruby_version = '>= 1.9.2'
end
