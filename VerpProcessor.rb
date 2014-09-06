=begin rdoc

Description::  Verp Processor API
Copyright::    Igor Lesik 2014
Author::       Igor Lesik
License::      Distributed under the Boost Software License, Version 1.0.
               (See  http://www.boost.org/LICENSE_1_0.txt)

=end

require 'logger'
require 'erb'

require_relative 'VerpMethods'

module Verp

class Processor

  def initialize(log, options)
    @log = log
    @log.debug("Command line options: #{options}")
    @option = options
  end

  def run
    @log.debug('Start')
    @option.inputs.each do |input|
      @log.debug("input: #{input}")
      process_file input
    end
  end

  def process_file(filename)
    if not File.exist? filename
      puts "File does not exist: #{filename}"
      return false
    end
    template = File.read(filename)
    renderer = ERB.new(template, 0, '%><>-')
    translator = Verp::TranslationObject.new(filename, self)
    output = 'something went wrong if you see this'
    begin
      output = renderer.result(translator.get_binding)
    rescue Verp::VerificationError => failure
      errline = failure.backtrace.grep(/^\(erb\)/)[0].split(':')[1].to_i
      errline_text = template.split("\n")[errline-1]
      output = "Assertion failed: #{failure.message}, line #{errline}: #{errline_text}"
    rescue RuntimeError => e
      output = "Runtime error: #{e.message}"
    rescue NoMethodError => e
      output = "Undefined method: #{e.message}"
    ensure
      #
    end
    @option.outputfile.puts output
    true
  end

end

end
