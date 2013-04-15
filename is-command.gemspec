# encoding: utf-8

require './lib/is/command'

Gem::Specification.new do |g|
  g.name = 'is-command'
  g.version = Is::Command::VERSION
  g.summary = 'Multicommand apps helper'
  g.author = 'Ivan Shikhalev'
  g.email = 'shikhalev@gmail.com'
  g.description = g.summary + '.'
  g.homepage = 'https://github.com/shikhalev/gems/'
  g.license = 'GNU GPL'

  g.files = [ 'lib/is/command.rb', '.yardopts' ]
  g.require_path = 'lib'
end
