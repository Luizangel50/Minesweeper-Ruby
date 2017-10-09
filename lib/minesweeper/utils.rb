module BOARD_STATES
  UNCLICKED = 0
  EMPTY = 1
  BOMBED = 2
  FLAGGED = 3
  NEARBOMB = 4
end

class SimplePrinter

  ## Public Methods
  public
  def initialize()
    @unknow_cell_sym = "."
    @clear_cell_sym = " "
    @bomb_sym = "#"
    @flag_sym = "F"
  end

  def print(board)
    fail ArgumentError, "Invalid Minesweeper Board" if(board == nil)

    puts
    board.map { 
      |x| puts x.map {
        |y| 
        if y.include? BOARD_STATES::FLAGGED
          printf "%3s  |", @flag_sym
        elsif y.include? BOARD_STATES::BOMBED
          printf "%3s  |", @bomb_sym
        elsif y.include? BOARD_STATES::UNCLICKED
          printf "%3s  |", @unknow_cell_sym
        elsif y.empty?
          printf "%3s  |", @clear_cell_sym
        elsif
          bombs_arround = y.count(BOARD_STATES::NEARBOMB)
          printf "%3s  |", bombs_arround
        end
      }.join("")
      printf "\n"
    }
  end

  def board_format
    puts "----- Board Simple Printer -----"
    puts "Printer symbols:"
    puts "Unclicked cell -> (#{@unknow_cell_sym})"
    puts "Clicked and empty cell -> (#{@clear_cell_sym})"
    puts "Bombed cell -> (#{@bomb_sym})"
    puts "Flagged cell -> (#{@flag_sym})"
    puts "Cell with bombs around -> (n), n is integer between 1 and 8"
    puts "--------------------------------"
  end

end


class PrettyPrinter
  
  ## Public Methods
  public
  def initialize(unknow_cell_sym = nil, clear_cell_sym = nil, bomb_sym = nil, flag_sym = nil)
    @unknow_cell_sym = unknow_cell_sym || "."
    @clear_cell_sym = clear_cell_sym || " "
    @bomb_sym = bomb_sym || "#"
    @flag_sym = flag_sym || "F"
    fail ArgumentError, "Board Symbols can have at most 2 caracters" if (@unknow_cell_sym.length > 2) or
                                                                        (@clear_cell_sym.length > 2) or
                                                                        (@bomb_sym.length > 2) or
                                                                        (@flag_sym.length > 2)
    board_format
  end

  def print(board)
    fail ArgumentError, "Invalid Minesweeper Board" if(board == nil)

    puts
    board.each_index { 
      |y|
      printf "Line %3s |", y
      board[y].each_index {
        |x| 
        if board[y][x].include? BOARD_STATES::FLAGGED
          printf "%3s  |", @flag_sym
        elsif board[y][x].include? BOARD_STATES::BOMBED
          printf "%3s  |", @bomb_sym
        elsif board[y][x].include? BOARD_STATES::UNCLICKED
          printf "%3s  |", @unknow_cell_sym
        elsif board[y][x].empty?
          printf "%3s  |", @clear_cell_sym
        elsif
          bombs_arround = board[y][x].count(BOARD_STATES::NEARBOMB)
          printf "%3s  |", bombs_arround
        end
      }
      printf "\n"
    }
  end

  def change_format(unknow_cell_sym = nil, clear_cell_sym = nil, bomb_sym = nil, flag_sym = nil)
    @unknow_cell_sym = unknow_cell_sym || @unknow_cell_sym
    @clear_cell_sym = clear_cell_sym || @clear_cell_sym
    @bomb_sym = bomb_sym || @bomb_sym
    @flag_sym = flag_sym || @flag_sym
    fail ArgumentError, "Board Symbols can have at most 2 caracters" if (@unknow_cell_sym.length > 2) or
                                                                        (@clear_cell_sym.length > 2) or
                                                                        (@bomb_sym.length > 2) or
                                                                        (@flag_sym.length > 2)
    board_format
  end

  def board_format
    puts "----- Board Pretty Printer -----"
    puts "Printer symbols:"
    puts "Unclicked cell -> (#{@unknow_cell_sym})"
    puts "Clicked and empty cell -> (#{@clear_cell_sym})"
    puts "Bombed cell -> (#{@bomb_sym})"
    puts "Flagged cell -> (#{@flag_sym})"
    puts "Cell with bombs around -> (n), n is integer between 1 and 8"
    puts "--------------------------------"
  end
  
end
