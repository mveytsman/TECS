class Command
  def initialize(line, symbol_table)
    @line = line
  end
end

class ACommand < Command
  attr_accessor :address, :prefix
  @@prefix = '0'
  def initialize(line, symbol_table)
    symbol = line[1..-1]
    if symbol =~ /^\d+$/
      @address = symbol.to_i.to_s(2).rjust(15, '0')
    else
      @address = symbol_table.get(symbol).to_s(2).rjust(15, '0')
    end
    super(line, symbol_table)
  end
  
  def code
    return @@prefix + @address
  end
end

class CCommand < Command
  attr_accessor :address, :prefix
  @@prefix = '111'
  @@dests = [nil, 'M', 'D', 'MD', 'A', 'AM', 'AD', 'AMD']
  @@comps = { 
    "0"   => "0101010",
    "1"   => "0111111",
    "-1"  => "0111010",
    "D"   => "0001100",
    "A"   => "0110000",
    "M"   => "1110000",
    "!D"  => "0001101",
    "!A"  => "0110001",
    "!M"  => "1110001",
    "-D"  => "0001111",
    "-A"  => "0110011",
    "-M"  => "1110011",
    "D+1" => "0011111",
    "A+1" => "0110111",
    "M+1" => "1110111",
    "D-1" => "0001110",
    "A-1" => "0110010",
    "M-1" => "1110010",
    "D+A" => "0000010",
    "D+M" => "1000010",
    "D-A" => "0010011",
    "D-M" => "1010011",
    "A-D" => "0000111",
    "M-D" => "1000111",
    "D&A" => "0000000",
    "D&M" => "1000000",
    "D|A" => "0010101",
    "D|M" => "1010101",
  }
  @@jumps = [nil, 'JGT', 'JEQ', 'JGE', 'JLT', 'JNE', 'JLE', 'JMP']

  def initialize(line, symbol_table)
    if line =~ /^.*=.*$/ #command is X=Y
      dest_symbol,comp_symbol = line.split('=')
      jump_symbol = nil
    elsif line =~ /^.*;.*$/ #command is X;Y
      comp_symbol, jump_symbol = line.split(';')
      dest_symbol = nil
    end
    @dest = @@dests.index(dest_symbol).to_i.to_s(2).rjust(3, '0')
    @comp = @@comps[comp_symbol]
    @jump = @@jumps.index(jump_symbol).to_i.to_s(2).rjust(3, '0')
    super(line, symbol_table)
  end
  
  def code
    return @@prefix + @comp + @dest + @jump
  end
end

class SymbolTable
  attr_accessor :ram_counter, :ram, :rom_counter, :rom
  def initialize
    @ram = {
      'SP' => 0,
      'LCL' => 1,
      'ARG' => 2,
      'THIS' => 3,
      'THAT' => 4,
      'R0' => 0,
      'R1' => 1,
      'R2' => 2,
      'R3' => 3,
      'R4' => 4,
      'R5' => 5,
      'R6' => 6, 
      'R7' => 7,
      'R8' => 8,
      'R9' => 9,
      'R10' => 10,
      'R11' => 11,
      'R12' => 12,
      'R13' => 13,
      'R14' => 14,
      'R15' => 15,
      'SCREEN' => 16384,
      'KBD' => 24576,
    }
    @rom = {}
    @ram_counter = 16
    @rom_counter = 0
  end
  def process(line)
    if line =~ /^\(.*\)$/
      @rom[line[1..-2]] = @rom_counter
    else
      @rom_counter += 1
    end
  end
  def get(symbol)
    if @rom[symbol] 
      return @rom[symbol]
    elsif @ram[symbol] 
      return @ram[symbol] 
    else
      @ram[symbol] = @ram_counter
      @ram_counter += 1
      return @ram[symbol]
    end
  end
end


s = SymbolTable.new

File.open(ARGV[0], "r").each do |l|
  l.gsub!(/\/\/.*/, '')
  l.chomp!
  l.strip!
  if not l.empty? and not l.start_with?("//")
    s.process(l)
  end
end

out = File.open(ARGV[1], "w")

File.open(ARGV[0], "r").each do |l|
  l.gsub!(/\/\/.*/, '')
  l.chomp!
  l.strip!
  if not l.empty? and not l.start_with?("//") and not l =~ /^\(.*\)$/
    if l.start_with?('@')
      command = ACommand.new(l, s)
      out.puts command.code
    else
      command = CCommand.new(l, s)
      out.puts command.code
    end
  end
end

out.close
