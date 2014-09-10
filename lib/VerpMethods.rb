=begin rdoc

Description::  Module that defines methods that could be used in template.
Copyright::    Igor Lesik 2014
Author::       Igor Lesik
License::      Distributed under the Boost Software License, Version 1.0.
               (See  http://www.boost.org/LICENSE_1_0.txt)

=end

module Verp

# This exception is thrown when assert() expression returns false.
class VerificationError < RuntimeError
end

module Methods

  def date
    DateTime.now
  end

  def assert(expr)
    unless expr
      message = "assert failed"
      raise VerificationError, message
    end
  end

  # verify is like assert but allows for big chunk of code
  # to be evaluated
  def verify(&block)
    raise VerificationError, "verify failed" unless yield
  end
end

class TranslationObject
  include Verp::Methods

  attr_reader :input_file_name

  def initialize(input_filename, options, log, processor)
    @input_file_name = input_filename
    @options = options
    @log = log
    @processor = processor
  end

  def get_binding
    binding
  end

  def include_definition(filename)
    path = find_file filename
    @log.debug("include file: #{path}")
    return false if path.nil?
    File.open(path, "r") do |file|
      text = file.read
      instance_eval(text)
    end
    true
  end

  def mixin(filename)
    path = find_file filename
    @log.debug("mixin file: #{path}")
    return false if path.nil?

    @processor.process_file path
  end

  def find_file(filename)
    for incdir in @options.includes
      path = File.join(incdir, filename)
      return path if File.exist?(path)
    end
    nil
  end
end

end
