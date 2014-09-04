=begin rdoc

Description::  Verp command line options
Copyright::    Igor Lesik 2014
Author::       Igor Lesik
License::      Distributed under the Boost Software License, Version 1.0.
               (See  http://www.boost.org/LICENSE_1_0.txt)

=end

require 'optparse'
require 'optparse/time'
require 'ostruct'

module Verp

class Options

  #
  # Return a structure describing the options.
  #
  def self.parse(log, args)
    # The options specified on the command line will be collected in *options*.
    # We set default values here.
    options = OpenStruct.new
    options.log = 'vert.log'

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: verp-run.rb [options]"

      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-l", "--log FILE", "Log file") do |file|
        options.log = file
      end

      opts.separator ""
      opts.separator "Common options:"

      # No argument, shows at tail.  This will print an options summary.
      # Try it and see!
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end

      # Typical switch to print the version.
      opts.on_tail("--version", "Show version") do
        puts Verp::VERSION
        exit
      end
    end

    opt_parser.parse!(args)
    options
  end  # parse()

end

end
