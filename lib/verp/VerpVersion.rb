=begin rdoc

Description::  Version number
Copyright::    Igor Lesik 2014
Author::       Igor Lesik
License::      Distributed under the Boost Software License, Version 1.0.
               (See  http://www.boost.org/LICENSE_1_0.txt)

=end

module Verp

  VERSION_MAJOR   = 0
  VERSION_MINOR   = 0
  VERSION_RELEASE = 1
  VERSION_DATE    = 20140923

  VERSION = "#{VERSION_MAJOR}.#{VERSION_MINOR}.#{VERSION_RELEASE}"

  def self.version
    VERSION
  end

end
