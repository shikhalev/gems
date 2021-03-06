# encoding: utf-8

require 'is/build'
require './lib/is/command'

Gem::Specification.new do |g|
  g.name = 'is-command'
  g.version = Is::Command::VERSION
  g.summary = 'Multicommand apps helper'
  g.author = 'Ivan Shikhalev'
  g.email = 'shikhalev@gmail.com'
  g.description = g.summary + '.'
  g.homepage = 'https://github.com/shikhalev/gems/'
  g.license = 'GNU LGPL'

  g.files = [ 'lib/is/command.rb', '.yardopts' ]

  g.mkbuild

  g.require_path = 'lib'
  g.required_ruby_version = '>= 1.9.2'
end
