module Sudoku
  class Cell

    attr_accessor :id, :values, :solution

    def initialize(id)
    # Cell represents each small square on a Sudoku board
    # Cell's solution must be an integer between 1 and 9
      @id       =  id
      @values   =  (1..9).to_a # Values that are possible solutions.
      @solution =  nil # Cell solution value.  Value displayed on board.
    end

    def set_solution(solution)
      @solution = solution
      @values = [solution]
    end

    def update_cell_val(val)
      # Eliminates one or many values from possible solutions.
      # Sets solution if only one possible value remains.
      unless @values == val || @values.length == 1
        @values.delete_if{|x| val.include?(x)}
        self.set_solution(@values[0]) if @values.length == 1
      end
    end

    def update_cell_triples(val)
      # Updates possible cell values when solving for triple et quads
      # Triple et quad represents three cells in one collection do not contain
      # any other numbers other than the three possible values
      # If self is not one of the three cells, The three values of the triple et quad
      # can be removed from self's possible solutions

      unless self.is_a_triple?(val) || @values.length == 1
        @values.delete_if{|x| val.include?(x)}
        self.set_solution(@values[0]) if @values.length == 1
      end
    end

    def is_a_triple?(val)
    # Helper method to determine if self is part of a triple et quad
      return false if @values.length > 3
      includes = true.tap do |includes|
        if @values.length >= val.length
          val.each { |v| break unless @values.include?(v) }
        else
          @values.each { |v| break unless val.include?(v) }
        end
      end
    end

    def row_head_id
      # Returns the ID of first cell of self's row
      case @id
      when 1..9
        return 1
      when 10..18
        return 10
      when 19..27
        return 19
      when 28..36
        return 28
      when 37..45
        return 37
      when 46..54
        return 46
      when 55..63
        return 55
      when 64..72
        return 64
      when 73..81
        return 73
      end
    end

    def col_head_id
      # Returns the ID of first cell of self's column
      @id % 9 == 0 ? 9 : (id % 9)
    end

    def block
      # Block is a 3X3 collection of cells.
      # There are 9 blocks on the board numbered 1-9 moving from top left to bottom right.
      # Method returns the block of cells self is in
      populate_blocks.values.each_with_index do |block, index|
        break populate_blocks[index + 1] if block.include?(@id)
      end
    end

    def print_cell
      @solution.nil? ? print("___|") : print("_#{@solution}_|")
    end

    def populate_blocks
      # Cell IDs by block
      # i.e. Block 1 contains the first 3 cells of the first 3 rows.
      blocks = {}.tap do |blocks|
        blocks[1] = [1, 2, 3, 10, 11, 12, 19, 20, 21]
        blocks[2] = [4, 5, 6, 13, 14, 15, 22, 23, 24]
        blocks[3] = [7, 8, 9, 16, 17, 18, 25, 26, 27]
        blocks[4] = [28, 29, 30, 37, 38, 39, 46, 47, 48]
        blocks[5] = [31, 32, 33, 40, 41, 42, 49, 50, 51]
        blocks[6] = [34, 35, 36, 43, 44, 45, 52, 53, 54]
        blocks[7] = [55, 56, 57, 64, 65, 66, 73, 74, 75]
        blocks[8] = [58, 59, 60, 67, 68, 69, 76, 77, 78]
        blocks[9] = [61, 62, 63, 70, 71, 72, 79, 80, 81]
      end
    end
  end
end