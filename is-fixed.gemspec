# encoding: utf-8

require 'is/build'
require './lib/is/fixed'

Gem::Specification.new do |g|
  g.name = 'is-fixed'
  g.version = Fixed::VERSION
  g.summary = 'Provides a fixed point numeric class'
  g.author = 'Ivan Shikhalev'
  g.email = 'shikhalev@gmail.com'
  g.description = g.summary + '.'
  g.homepage = 'https://github.com/shikhalev/gems/'
  g.license = 'GNU LGPL'

  g.files = [ 'lib/is/fixed.rb', '.yardopts' ]

  g.mkbuild

  g.require_path = 'lib'
  g.required_ruby_version = '>= 1.9.2'
end

