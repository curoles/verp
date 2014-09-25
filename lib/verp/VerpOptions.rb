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

# VERP namespace module
#
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
    options.inputs = []
    options.outputfile = $stdout
    options.includes = ['.']
    options.auto = false

    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: verp-run.rb [options]"

      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-l", "--log FILE", "Log file") do |file|
        options.log = file
      end

      opts.on("-o", "--output FILE", "Output file") do |filename|
        new_output_file = File.open(filename, "w")
        options.outputfile = new_output_file if new_output_file
      end

      opts.on("-i", "--input FILE", "Input file") do |filename|
        options.inputs << OpenStruct.new(:file => true, :data => filename)
      end

      opts.on("-s", "--input-string TEXT", "Input string") do |text|
        options.inputs << OpenStruct.new(:file => false, :data => text)
      end

      opts.on("-I", "--include PATH", "Include directory") do |path|
        options.includes << path
      end

      opts.on("-a", "--[no-]auto", "Auto connecting") do |auto|
        options.auto = auto
      end

      opts.separator ""
      opts.separator "Common options:"

      # No argument, shows at tail.  This will print an options summary.
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end

      # Typical switch to print the version.
      opts.on_tail("--version", "Show version") do
        puts "Ruby version: #{RUBY_VERSION}"
        puts "Verilog ERB Pre-Processor version #{Verp::VERSION}"
        exit
      end
    end

    opt_parser.parse!(args)

    # Not parsed options must be input file names
    args.each{ |fn| options.inputs << OpenStruct.new(:file => true, :data => fn) }

    options
  end  # parse()

end

end
