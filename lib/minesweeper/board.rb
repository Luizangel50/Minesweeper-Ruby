require_relative "./utils.rb"

class Board
  attr_reader :height, :width, :bombs_qnt, :cells, :board_state

  ## Public Methods
  public
  def initialize(width, height, bombs_qnt)
    fail ArgumentError, "All board parameters must be positive integers" if (!height.is_a? Integer) or 
                                                                            (!width.is_a? Integer) or 
                                                                            (!bombs_qnt.is_a? Integer) or
                                                                            (height <= 0) or 
                                                                            (width <= 0) or 
                                                                            (bombs_qnt <= 0)
    @width, @height, @bombs_qnt = width, height, bombs_qnt
    @bombs_cells = Hash.new
    @game_ended = false
    @win = false
    @unclicked_cells = height * width

    generate_board
    verify_victory
  end

  def play(coord_x, coord_y)
    fail ArgumentError, "Flag x coordenate should be a positive integer minor or equal to #{width - 1}" if (!coord_x.is_a? Integer) or (coord_x < 0) or (coord_x >= width)
    fail ArgumentError, "Flag y coordenate should be a positive integer minor or equal to #{height - 1}" if (!coord_y.is_a? Integer) or (coord_y < 0) or (coord_y >= height)
    print "Play-> x: ", coord_x, "; y: ", coord_y, "\n"
    if @game_ended
      puts "Game already ended, cannot play anymore"
      return false
    elsif !@board_state_revealed[coord_y][coord_x].include? BOARD_STATES::UNCLICKED
      return false
    elsif @board_state_revealed[coord_y][coord_x].include? BOARD_STATES::FLAGGED
      return false
    elsif @board_state_revealed[coord_y][coord_x].include? BOARD_STATES::BOMBED
      # puts "Game ended. Sorry, but YOU LOST :["
      @board_state_revealed[coord_y][coord_x].delete(BOARD_STATES::UNCLICKED)
      @board_state[coord_y][coord_x].delete(BOARD_STATES::UNCLICKED)
      @board_state[coord_y][coord_x] << BOARD_STATES::BOMBED
      @game_ended = true
      @win = false
      return true
    end

    @board_state_revealed[coord_y][coord_x].delete(BOARD_STATES::UNCLICKED)
    @board_state[coord_y][coord_x] = @board_state_revealed[coord_y][coord_x]
    @unclicked_cells -= 1

    if !@board_state_revealed[coord_y][coord_x].include? BOARD_STATES::NEARBOMB
      discover_cells(coord_x, coord_y)
    end
    verify_victory
    return true
  end

  def flag(coord_x, coord_y)
    fail ArgumentError, "Flag x coordenate should be a positive integer minor or equal to #{width - 1}" if(coord_x < 0 or coord_x >= width)
    fail ArgumentError, "Flag y coordenate should be a positive integer minor or equal to #{height - 1}" if(coord_y < 0 or coord_y >= height)
    element = @board_state_revealed[coord_y][coord_x]
    print "Put or Remove Flag-> x: ", coord_x, "; y: ", coord_y, "\n"
    if element.include? BOARD_STATES::FLAGGED
      @board_state_revealed[coord_y][coord_x].delete(BOARD_STATES::FLAGGED)
      @board_state[coord_y][coord_x].delete(BOARD_STATES::FLAGGED)
      return true
    elsif element.include? BOARD_STATES::UNCLICKED
      @board_state_revealed[coord_y][coord_x] << BOARD_STATES::FLAGGED
      @board_state[coord_y][coord_x] << BOARD_STATES::FLAGGED
      return true
    end
    return false
  end

  def still_playing?
    return !@game_ended
  end

  def victory?
    return (@game_ended and @win)
  end

  def board_state(hash = nil)
    if hash == nil
      return @board_state
    elsif(@game_ended and hash[:xray])
      puts "Board State-> xRay On"
      return @board_state_revealed
    else
      puts "Board State-> xRay Off"
      return @board_state
    end

  end

  ### Debug: Simple print of non-xRayed Board
  # def print_board
  #   puts
  #   @board_state.map { 
  #     |x| puts x.map {
  #       |y| print y
  #     }.join("")
  #   }
  # end

  ## Private Methods
  private
  def generate_board
    print @width, " x ", @height, "\n"
    print @bombs_qnt, " bomb(s)\n"
    @board_state = Array.new(height) { Array.new(width) { [BOARD_STATES::UNCLICKED] } }
    @board_state_revealed = Array.new(height) { Array.new(width) { [BOARD_STATES::UNCLICKED] } }

    put_bombs
  end

  def put_bombs
    for bomb in 0..@bombs_qnt - 1
      pseudo_rand_x = rand(0..@width - 1)
      pseudo_rand_y = rand(0..@height - 1)
      while @bombs_cells[[pseudo_rand_x, pseudo_rand_y]]
        pseudo_rand_x = rand(0..@width - 1)
        pseudo_rand_y = rand(0..@height - 1)
      end
      @bombs_cells[[pseudo_rand_x, pseudo_rand_y]] = true
    end
    
    # Marking bombed cells
    @board_state_revealed.each_index { 
      |y| @board_state_revealed[y].each_index {
        |x|
          if @bombs_cells[[x, y]]
            @board_state_revealed[y][x] << BOARD_STATES::BOMBED           
          end
      }
    }

    # Mapping cells around the bomb
    @board_state_revealed.each_index { 
      |y| @board_state_revealed[y].each_index {
        |x|
          if @board_state_revealed[y][x].include? BOARD_STATES::BOMBED
            near_bombs(x, y)
          end
      }
    }

    ### Debug: Simple print to verify if board is correct
    # @board_state_revealed.each_index { 
    #   |y| @board_state_revealed[y].each_index {
    #     |x|
    #       print "line ", y, ", column ", x, ": ", @board_state_revealed[y][x],"\n"
    #   }
    # }
  end

  def near_bombs(bomb_x, bomb_y)
    directions = [{-1 => -1}, {-1 => 0}, {-1 => 1}, {0 => -1}, {0 => 1}, {1 => -1}, {1 => 0}, {1 => 1}]
    for direction in directions
      direction.each { 
        |key, value| 
        new_x = bomb_x + key
        new_y = bomb_y + value
        if(new_y >=0 and new_y < @height)
          if(new_x >= 0 and new_x < @width)
            @board_state_revealed[new_y][new_x] << BOARD_STATES::NEARBOMB
          end
        end
      }
    end
  end

  def discover_cells(coord_x, coord_y)
    neighbors_cells = neighbors(coord_x, coord_y)
    for neighbor_cell in neighbors_cells
      neighbor_cell.each {
        |key, value|
        if !@board_state_revealed[value][key].include? BOARD_STATES::UNCLICKED
          next
        elsif !@board_state_revealed[value][key].include? BOARD_STATES::FLAGGED
          next
        elsif !@board_state_revealed[value][key].include? BOARD_STATES::BOMBED
          next
        end

        @board_state_revealed[value][key].delete(BOARD_STATES::UNCLICKED)
        @board_state[value][key].delete(BOARD_STATES::UNCLICKED)
        @unclicked_cells -= 1

        if !@board_state_revealed[value][key].include? BOARD_STATES::NEARBOMB
          discover_cells(key, value)
        end
      }
    end
  end

  def neighbors(coord_x, coord_y) 
    directions = [{-1 => -1}, {-1 => 0}, {-1 => 1}, {0 => -1}, {0 => 1}, {1 => -1}, {1 => 0}, {1 => 1}]
    list = []
    for direction in directions
      direction.each { 
        |key, value| 
        new_x = coord_x + key
        new_y = coord_y + value
        if(new_y >=0 and new_y < @height)
          if(new_x >= 0 and new_x < @width)
            list << {new_x => new_y}
          end
        end
      }
    end
    return list
  end

  def verify_victory
    if @game_ended
      return
    end
    unclicked_bombs = 0
    @board_state_revealed.each_index { 
      |y| @board_state_revealed[y].each_index {
        |x|
          if(@board_state_revealed[y][x].include? BOARD_STATES::UNCLICKED and 
            @board_state_revealed[y][x].include? BOARD_STATES::BOMBED)
            unclicked_bombs += 1
          end
      }
    }
    if @unclicked_cells == unclicked_bombs
      # puts "Game ended, YOU WON! \\o/"
      @game_ended = true
      @win = true
    end
  end

end