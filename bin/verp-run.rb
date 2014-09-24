#!/usr/bin/env ruby
#
=begin rdoc

Description::  VERP executable stript entry point
Copyright::    Igor Lesik 2014
Author::       Igor Lesik
License::      Distributed under the Boost Software License, Version 1.0.
               (See  http://www.boost.org/LICENSE_1_0.txt)

=end


require 'logger'

require_relative '../lib/verp'


module Verp

class Main < Logger::Application

  def initialize(args)
    super('VERP')
    level=DEBUG
    options = Verp::Options.parse(@log, args)
    set_log(options.log)
    @log.debug("Ruby version: #{RUBY_VERSION}")
    @log.debug("Verilog ERB Pre-Processor version: #{Verp::VERSION}")
    @log.debug("Options: #{options}")
    @processor = Verp::Processor.new(@log, options)
  end

  def run
    @processor.run 
    #@log.debug("Exiting VERP, bye!")
  end

  def trap_signal_INT(signo)
    Signal.trap(signo, "DEFAULT")
  end
end

end


verp = Verp::Main.new(ARGV)

Signal.trap("INT") do |signo|
  puts "Signal: #{Signal.signame(signo)} (Ctrl-C)"
  verp.trap_signal_INT(signo)
end

verp.start

