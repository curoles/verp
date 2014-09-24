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
    'begin', 'end', 'if', 'else', 'parameter', 'posedge', 'negedge']

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

  attr_reader :vmodules

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
        vmodules << {:local => true, :token_from => found_id, :token_to => id}
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
    vmodule[:submodules] = []
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
      case
      when ['input', 'output'].include?(s)
        name_pos=pos
        while name_pos < token_to and tok(pos)[:s] != ';'
          pos += 1
        end
        wire_name = tok(pos-1)[:s]
        wire = vmodule[:wires].select{|wire| wire[:name] == wire_name }
        wire[0][:dir] = s
      when s == 'wire'
        #TODO can be pin or internal wire
        wire_name = tok(pos+1)[:s]; pos += 1 #FIXME
        vmodule[:wires] << {:pin => false, :dir => 'input', :name => wire_name}
      #when id and then another id
      when (tok(pos)[:type] == :id and tok(pos+1)[:type] == :id)
        subm_class = tok(pos)[:s]
        subm_name = tok(pos+1)[:s]
        vsubmodule = {:type => subm_class, :name => subm_name, :pins => []}
        pos = analyze_pin_connection(pos + 2, token_to, vsubmodule)
        vmodule[:submodules] << vsubmodule
      end
      pos += 1
    end
  end

  def analyze_pin_connection(start_pos, end_pos, vsubmodule)
    pos = start_pos
    while pos < end_pos
      s = tok(pos)[:s]
      case
      when s == ';'
        return pos
      when s == '('
      when s == ')'
      when (s == '.' and tok(pos+1)[:type] == :id)
        pin_name = tok(pos+1)[:s]
        external_pin = tok(pos+3)[:s]
        puts "#{pin_name} connected to #{external_pin}"
        vsubmodule[:pins] << {:name => pin_name, :ext => external_pin}
      else
        puts "!!! #{s}"
      end
      pos += 1
    end

    pos
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
    @analyzer = Verp::VerilogAnalyzer.new
  end

  def run(input)
    @analyzer.run(input)
    auto_connect_modules
  end

  def auto_connect_modules
    @analyzer.vmodules.each do |vmodule|
      next if not vmodule[:local]
      submodules = vmodule[:submodules]
      missing_wires = [];
      submodules.each do |instance|
        #puts "=========== NEED TO CONNECT ===========\n#{instance}"
        type = instance[:type]
        vmods_with_def = @analyzer.vmodules.select {|m| m[:name] == type}
        if not vmods_with_def.empty?
          vmod_with_def = vmods_with_def[0]
          vmod_pins = vmod_with_def[:wires].select {|wire| wire[:pin]}
          already_connected_pins = instance[:pins]
          disconnected_pins = vmod_pins.select do |pin|
            found = already_connected_pins.select {|p| p[:name]==pin[:name]}
            found.empty?
          end
          puts ">>>>>>> disconnected pins:#{disconnected_pins}"
          disconnected_pins.each do |p|
            existing_wires_with_this_name = vmodule[:wires].select {|wire| wire[:name] == p[:name]}
            wire_exist = !existing_wires_with_this_name.empty?
            missing_wires << p[:name] unless (missing_wires.include?(p[:name]) or wire_exist)
          end
        end
      end
      puts "+++ missing_wires: #{missing_wires} in #{vmodule[:name]}"
    end
  end

end

end
