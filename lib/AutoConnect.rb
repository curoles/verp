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
  BlockComment = /\/\*.*?\*\//m
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
        when /[a-zA-Z_]\w*/
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

class VerilogAnalyzer

  def initialize
    @tokens = []
    @vmodules = []
  end

  def run(text)
    scanner = Verp::VerilogScanner.new(text)
    @tokens = scanner.run
    @vmodules = find_modules
    @vmodules.each {|vmodule| analyze vmodule}
    #@tokens
    @vmodules
  end

  def tok(id)
    @tokens[id]
  end

  def find_modules
    vmodules = []
    found, found_id = false, -1
    @tokens.each_with_index do |token, id|
      found, found_id = true, id if token[:type] == :keyword and token[:s] == 'module'
      if found and token[:type] == :keyword and token[:s] == 'endmodule' then
        vmodules << {:token_from => found_id, :token_to => id}
        found, found_id = false, -1
      end
    end
    vmodules
  end

  def analyze(vmodule)
    module_begin, module_end = vmodule[:token_from], vmodule[:token_to] 
    declaration_end = nil
    module_begin.upto(module_end) do |token_id|
      if @tokens[token_id][:s] == ';'
        declaration_end = token_id
        break
      end
    end

    report_Verilog_syntax_error(
      "module declaration no trailing ';': #{@tokens[module_begin]}") if not declaration_end

    vmodule[:wires] = []
    analyze_declaration(vmodule, module_begin, declaration_end)
    analyze_definition(vmodule, declaration_end + 1, module_end)
  end

  def analyze_declaration(vmodule, token_from, token_to)
    new_wire = Proc.new { {:pin => true, :dir => 'input', :name => '?'} }
    pos = token_from + 1
    #if token[:s] == '#'
    vmodule[:name] = tok(pos)[:s]
    pos += 1
    if tok(pos)[:s] == '(' then
      wire = new_wire.call
      while (pos += 1) < token_to
        s = tok(pos)[:s]
        case s
          when ')'
            break
          when ','
            wire = new_wire.call
          when 'input','output','inout'
            wire[:dir] = s
          when 'reg'
            #TODO
          else
            if tok(pos)[:type] == :id then
              wire[:name] = s
              vmodule[:wires] << wire
              wire = new_wire.call
            end
        end
      end
    end
  end

  def analyze_definition(vmodule, token_from, token_to)
    pos = token_from
    while pos < token_to
      s = tok(pos)[:s]
      case s
      when 'input', 'output'
        name_pos=pos
        while name_pos < token_to and tok(pos)[:s] != ';'
          pos += 1
        end
        wire_name = tok(pos-1)[:s]
        wire = vmodule[:wires].select{|wire| wire[:name] == wire_name }
        wire[0][:dir] = s
      end
      pos += 1
    end
  end

  def report_Verilog_syntax_error(message)
    raise VerilogSyntaxError, message
  end

end

class AutoConnect

  #attr_reader :input_file_name

  def initialize(options, log)
    @options = options
    @log = log
  end

  def run(input)
    analyzer = Verp::VerilogAnalyzer.new
    analyzer.run(input)
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
