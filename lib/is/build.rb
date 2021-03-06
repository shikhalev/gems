# encoding: utf-8

require 'digest/sha1'
require 'rubygems'

module Is

  module Build

    VERSION = '0.2.0'

  end

end

class Gem::Specification

  def mkhash
    s = File.read @spec
    files.each do |f|
      s += File.read f
    end
    Digest::SHA1.hexdigest s
  end

  def mkbuild prefix = ''
    @spec = caller[0].split(':')[0]
    file = "./.#{name}.vers"
    if File.exists? file
      data = File.read(file)
      vers = eval(data)
    else
      vers = {}
    end
    hash = mkhash
    vx = version.to_s + '.' + prefix
    if vers[vx]
      current = vers[vx]
      if current[:hash] != hash
        current[:build] += 1
        current[:hash] = hash
      end
    else
      current = { :hash => hash, :build => 0 }
    end
    vers[vx] = current
    File.open file, 'w' do |f|
      f.puts vers.inspect
    end
    if current[:build] && (current[:build] != 0 || prefix != '')
      self.version = vx + current[:build].to_s
    end
  end

end
