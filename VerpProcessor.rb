=begin rdoc

Description::  Verp Processor API
Copyright::    Igor Lesik 2014
Author::       Igor Lesik
License::      Distributed under the Boost Software License, Version 1.0.
               (See  http://www.boost.org/LICENSE_1_0.txt)

=end

require 'logger'

module Verp

class Processor

  def initialize(log, option)
    @log = log
    @log.debug("Command line options: #{option}")
  end

  def run
    @log.debug('Start')
  end

end

end
