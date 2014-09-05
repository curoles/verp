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
    renderer = ERB.new(File.read(filename), 0, '%><>-')
    translator = Verp::TranslationObject.new(filename)
    output = renderer.result(translator.get_binding)
    @option.outputfile.puts output
    true
  end

end

end
