=begin rdoc

Description::  Module that defines methods that could be used in template.
Copyright::    Igor Lesik 2014
Author::       Igor Lesik
License::      Distributed under the Boost Software License, Version 1.0.
               (See  http://www.boost.org/LICENSE_1_0.txt)

=end

module Verp

module Methods

  def date
    DateTime.now
  end

end

class TranslationObject
  include Verp::Methods

  attr_reader :input_file_name

  def initialize(input_filename)
    @input_file_name = input_filename
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

end

end
