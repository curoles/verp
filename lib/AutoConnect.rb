=begin rdoc

Description::  Connect submodules automatically.
Copyright::    Igor Lesik 2014
Author::       Igor Lesik
License::      Distributed under the Boost Software License, Version 1.0.
               (See  http://www.boost.org/LICENSE_1_0.txt)

=end

module Verp

class VerilogSyntaxError < RuntimeError
end

class VerilogScanner

  LineComment = /\/{2}.*$/
  BlockComment = /\/\*.*\*\//m
  Keywords = ['module', 'endmodule', 'input', 'output', 'inout', 'reg', 'always',
    'begin', 'end', 'if', 'else']

  def initialize(string)
    @string = string
    @scan = StringScanner.new(@string, false)
    @pos = 0
  end

  def run
    tokens = []
    @pos = 0
    until @scan.eos?
      @pos = @scan.pos
      sym = @scan.peek(1)
      #puts "#{@scan.pos}??? #{sym}"
      case sym
      when /\s/
        @scan.skip_until /\s+/
      when /\//
        case
        when @scan.match?(/\/{2}/)
          @scan.skip_until LineComment
        when @scan.match?(/\/\*/)
          ok = @scan.skip_until BlockComment
          report_Verilog_syntax_error("incomplete block comment") if not ok
        else
          c = @scan.getch
          tokens << new_token(c, :op)
        end
      when /\w/
        word = @scan.scan(/\w+/)
        case word
        when *Keywords
          tokens << new_token(word, :keyword)
        when /[a-zA-Z_]\w+/
          tokens << new_token(word, :id)
        else
          tokens << new_token(word, :unknown)
        end
      when /[\+\-\*\=]/
          c = @scan.getch
          tokens << new_token(c, :op)
      when /;/
          c = @scan.scan(/;+/)
          tokens << new_token(c, :statement_end)
      else
        c = @scan.getch
        tokens << new_token(c, :unknown)
      end
    end
    tokens
  end

  def report_Verilog_syntax_error(message)
    pos = @pos
    line_num = @scan.string[0, pos].lines.count
    code = @scan.string[pos,80][/.*$/,0]
    full_message = "#{message}; position=#{pos}, line #{line_num+1}: #{code}"
    raise VerilogSyntaxError, full_message
  end

  def new_token(s, type)
    {:pos => @pos, :s => s, :type => type}
  end
end

class AutoConnect

  #attr_reader :input_file_name

  def initialize(options, log)
    @options = options
    @log = log
  end

  def run(input)
    @scanner = Verp::VerilogScanner.new(input)
    @scanner.run
    #vmodules = find_modules(input)
    #output = vmodules.empty? ? input : auto_connect(vmodules)
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