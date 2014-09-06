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

  def initialize(input_filename, processor)
    @input_file_name = input_filename
    @processor = processor
  end

  def get_binding
    binding
  end

  def include_definition(filename)
    File.open(filename, "r") do |file|
      text = file.read
      instance_eval(text)
    end
  end

  def mixin(filename)
    @processor.process_file filename
  end

end

end
