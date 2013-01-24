require_relative 'board'
require_relative 'populated_board'

module Sudoku
  class Game
    attr_accessor :board, :beginning_board, :player

    def initialize
      @board           = Board.new
      @beginning_board = Board.new
    end

  ###################################################################
  #################### CORE GAME PLAYING METHODS ####################
  ###################################################################

    def play
      self.game_setup
    end

    def quit_game
      puts "Thanks for playing."
    end

    def game_setup
    # Existing board allows user to play a pre-populated board.
    # Creating his/her own board forces user to input 9 rows of values representing
    # the beginning board
    # No validations exist to ensure a user generated board is valid or solvable.
      puts "Hi. Welcome to the Sudoku Arena.  Would you like to play an existing board or create your own?  ('existing' / 'own')"
      loop do
        type = gets.chomp.downcase
        case type
        when 'existing'
          break self.select_existing_board
        when 'own'
          break self.custom_board_greeting
        when 'quit'
          break self.quit_game
        else
          puts "Please type 'existing' or 'own' or 'quit'."
        end
      end
    end

    def select_existing_board
    # User chooses difficulty level.
      board = Existing.new
      puts "\n" << "So you want to use an existing board.  What level are you in the mood for?  ('mild', 'medium', 'spicy', or 'en fuego')"
      loop do
        difficulty = gets.chomp.downcase
        if ['mild', 'medium', 'spicy', 'en fuego'].include?(difficulty)
          break setup_existing_board(board.send("#{difficulty}"))
        else
          puts "\n" << "Sorry. I didn't get that.  What are you in the mood for?  ('mild', 'medium', 'spicy', or 'en fuego')"
        end
      end
    end

    def custom_board_greeting
      puts "\n" << "Let's add one row at a time.  Each row should be in the following format with blank cells as '0's:"
      puts "0,0,0,0,0,0,0,0,0 would create a completely blank row."
      puts "0,2,0,3,0,0,8,0,0 would create a row with a few numbers populated to start."
      puts "\n" << "Let's give it a shot. If you change your mind, just type 'existing' to play an existing board or 'quit' to quit."
      self.setup_custom_board
    end

    def setup_custom_board
      row_id = 1
      loop do
        response = gets.chomp
        case response
        when 'quit'
          break self.quit_game
        when 'existing'
          break self.select_existing_board
        else
          row = self.parse_row(response)
          if self.validate_row(row)
            self.add_row(row, row_id)
            row_id == 9 ? (break self.set_board) : puts("Thanks.  Go ahead and add row #{row_id + 1}.")
            row_id += 1
          else
            puts "That wasn't quite right.  Try again."
          end
        end
      end
    end

    def setup_existing_board(board)
      @board.populate_board(board)
      self.set_board
    end

    def set_board
    # Check for duplicate solutions in any row, column or block
    # No validation board is actually solvable
    # Creates copy of board in case user wants to start over
      if @board.board_errors?
        @board.print_board
        puts "\n" << "Looks like you have some errors in the board.  Remember no column, row or block can have the same number.  Let's start over."
        self.revisit_custom_board
      else
        puts "The beginning board board is set."
        self.create_beginning_board
        @board.print_board
        self.start_playing
      end
    end

    def create_beginning_board
      beginning_cells = []
      @board.cells.each {|c| beginning_cells << c.dup}
      @beginning_board.instance_variable_set(:@cells, beginning_cells)
    end

    def start_playing
      puts "\n" << "Let's start playing."
      loop do
        puts "\n" << "To set a cell's value type 'set value'.  You can also 'print board', 'check answers', 'solve the puzzle' 'start over' or 'quit'."
        answer = gets.chomp.downcase
        case answer
        when 'set value'
          self.get_active_cell_id
        when 'print board'
          puts "\n" << "The Current Board"
          @board.print_board
        when 'check answers'
          @board.solved?
        when 'solve the puzzle'
          self.game_setup if @beginning_board.solve
        when 'start over'
          break self.game_setup
        when 'quit'
          break self.quit_game
        else
          puts "\n" << "Sorry.  I didn't get that."
        end
      end
    end

  ##################################################################
  ################## CUSTOM BOARD HELPER METHODS ###################
  ##################################################################

    def revisit_custom_board
    # Revisit beginning sequence for user generated board if previous user generated board
    # contained basic errors (i.e. duplicate solutions in a collection)
      puts "Each row should be in the following format with blank cells as '0's:"
      puts "0,0,0,0,0,0,0,0,0 would create a completely blank row."
      puts "0,2,0,3,0,0,8,0,0 would create a row with a few numbers populated to start."
      puts "\n"
      self.setup_custom_board
    end

    def add_row(row=[], row_id)
      @board.add_board_row(row, row_id)
    end

    def parse_row(str)
    # Helper method for basic row validation
      [].tap do |row|
        str.split(',').each {|v| row << v.to_i}
      end
    end

    def validate_row(row)
    # Basic validation for user generated row.
      return false unless row.length == 9
      row.each { |value| return false unless value.class == Fixnum || value >=0 && value <= 9 }
    end

  #################################################################
  ################### GAME PLAY HELPER METHODS ####################
  #################################################################

    def get_active_cell_id
    # Get cell ID user wishes to update.  Provide row and column information to confirm.
      puts "\n" << "Let's set the cell's value using its Location ID.  Location IDs start at 1 (upper left corner) and end at 81 (lower right corner) moving left to right and top to bottom."
      loop do
        puts "What is the ID of the cell you want to set?"
        answer = gets.chomp.downcase.to_i
        if answer.between?(1,81)
          print "\n" << "Cell #{answer} is in column #{@board.cell(answer).col_head_id} and row #{@board.cell(answer).row_head_id/9+1}.  "
          if @board.cell(answer).solution.nil?
            puts "It is currently unsolved."
          else
            puts "The cell's solution is currently #{@board.cell(answer).solution}."
          end
          self.confirm_id_selection(answer)
          break
        else
          puts "\n" << "The cell ID must be between 1 and 81."
        end
      end
    end

    def confirm_id_selection(id)
    # Provide user ability to confirm or change selection.
      puts "\n" << "Is this the cell you want to set? ('yes' / 'no')"
      loop do
        response = gets.chomp.downcase
        case response
        when 'no'
          break self.get_active_cell_id
        when 'yes'
          break self.set_cell_value(id)
        else
         puts "\n" << "Sorry.  I didn't get that.  Please type 'yes' or 'no'."
        end
      end
    end

    def set_cell_value(id)
    # Validates input value is between 1 and 9
    # Needs validation an integer and not a string or other is input
      loop do
        puts "What is the value you would like to set cell #{id} to?"
        value = gets.chomp.downcase.to_i
        if value.between?(1,9)
          @board.cell(id).set_solution(value)
          puts "Here is the updated board."
          break @board.print_board
        else
          puts "\n" << "The cell value must be between 1 and 9."
        end
      end
    end
  end
end