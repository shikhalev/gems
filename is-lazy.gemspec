# encoding: utf-8

require 'is/build'
require './lib/is/lazy'

Gem::Specification.new do |g|
  g.name = 'is-lazy'
  g.version = Is::Lazy::VERSION
  g.summary = 'Provides an object-placeholder for lazy and threaded calculations'
  g.author = 'Ivan Shikhalev'
  g.email = 'shikhalev@gmail.com'
  g.description = g.summary + '.'
  g.homepage = 'https://github.com/shikhalev/gems/'
  g.license = 'GNU LGPL'

  g.files = [ 'lib/is/lazy.rb', '.yardopts' ]

  g.mkbuild

  g.require_path = 'lib'
  g.required_ruby_version = '>= 1.9.2'
end

