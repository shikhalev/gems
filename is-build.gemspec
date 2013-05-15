# encoding: utf-8

require './lib/is/build'

Gem::Specification.new do |g|
  g.name = 'is-build'
  g.version = Is::Build::VERSION
  g.summary = 'Autoincrement build number'
  g.author = 'Ivan Shikhalev'
  g.email = 'shikhalev@gmail.com'
  g.description = g.summary + '.'
  g.homepage = 'https://github.com/shikhalev/gems'
  g.license = 'GNU LGPL'

  g.files = [ 'lib/is/build.rb', '.yardopts' ]

  g.mkbuild

  g.require_path = 'lib'
  g.required_ruby_version = '>= 1.9.2'
end

