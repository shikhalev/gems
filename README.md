
# Ruby Gems by Ivan Shikhalev

## Overview

### License

This code is distributed under the
{file:LICENSE.md GNU General Public License}

### Links

* [Project](https://github.com/shikhalev/gems) @ [GitHub](https://github.com/)
* [Tracker](https://github.com/shikhalev/gems/issues) &
[Wiki](https://github.com/shikhalev/gems/wiki) @ [GitHub](https://github.com/)
* [Documentation](http://rubydoc.info/github/shikhalev/gems/master/frames)
@ [RubyDoc.info](http://rubydoc.info/)

## “Command” Gem

This is helper for creating multi-command apps (like Git, for example).

Provides the {Is::Command} class.

### Usage example

#### Application

    require 'is/command'

    app = Is::Command::Application.new do

      key '-h', '--help' do
        puts "#{$0} -h|--help|<command> <files>"
        puts "\t-h, --help -- Show this help."
        puts "\taccess <files> -- Show access time for files."
        puts "\tcreate <files> -- Show creation time."
        puts "\tmodify <files> -- Show modification time."
        halt 0
      end

      action :access do |*args|
        args.each do |filename|
          puts "#{filename} => #{File.atime(filename)}"
        end
      end

      action :create do |*args|
        args.each do |filename|
          puts "#{filename} => #{File.ctime(filename)}"
        end
      end

      action :modify do |*args|
        args.each do |filename|
          puts "#{filename} => #{File.mtime(filename)}"
        end
      end

      default do
        $stderr.puts 'Command not found.'
        halt 1
      end

    end

    app.run    # <=> app.process *ARGV

#### One-block application

    require 'is/command'

    Is::Command.runapp do

      # ... key definitions like above

      # ... action definitions...

    end

#### Other object wrap

    require 'is/command'

    obj = Object.new
    obj.instance_eval do

      include Is::Command::Mixin    # sic!

      # ... key definitions like above

      # ... action definitions...

    end
    obj.process *ARGV

#### Global object mixed

    require 'is/command'

    include Is::Command::Mixin

    # ... key definitions like above

    # ... action definitions...

    process *ARGS

### Links

* [is-command-0.8.1](https://rubygems.org/gems/is-command) @
[RubyGems.org](https://rubygems.org/)

### ToDo

Console help automaker like the OptionParser.

## “Lazy” Gem

Provides an object-placeholder for lazy and threaded calculations.

See the {Is::Lazy} module.

### Links

* [is-lazy-0.9.0](https://rubygems.org/gems/is-lazy) @
[RubyGems.org](https://rubygems.org/)

## “Monkey” Gems

Set of the monkey-patches.

See the {Module}, {Object} etc.

### Links

* [is-monkey-0.1.0](https://rubygems.org/gems/is-monkey) @
[RubyGems.org](https://rubygems.org/)
