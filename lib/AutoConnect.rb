=begin rdoc

Description::  Connect submodules automatically.
Copyright::    Igor Lesik 2014
Author::       Igor Lesik
License::      Distributed under the Boost Software License, Version 1.0.
               (See  http://www.boost.org/LICENSE_1_0.txt)

=end

module Verp

class AutoConnect

  #attr_reader :input_file_name

  def initialize(options, log)
    @options = options
    @log = log
  end

  def run(input)
    vmodules = find_modules(input)
    output = vmodules.empty? ? input : auto_connect(vmodules)
  end

  def find_modules(text)
    vmodules = []
    begin_pos = scan_for('module', text)
    vmodules
  end

  def scan_for(s, text, pos = 0)
    nil
  end
end

end
