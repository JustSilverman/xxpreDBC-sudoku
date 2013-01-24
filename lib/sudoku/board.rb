require_relative 'collection'

module Sudoku
  class Board < Collection
  # Board represents 81 cells in a 9X9 square
  # Each board contains 9 rows, columns and blocks
  # Board can be represented by a two-dimensional hash of cells

    attr_accessor :cells, :solutions, :unsolved_cell_ids

    def initialize
    # Creates blank board. No cell contains a solution or any eliminated
    # possible solutions.
      @cells = []
      @solutions = []
      (1..81).to_a.each{ |id| @cells << Cell.new(id) }
    end

    def populate_board(rows)
    # Populates board with pre-populated two-dimensional hash
    # Blank cells are represented by 0's in the hash.
      (1..9).to_a.each do |r|
        (0..8).to_a.each do |c|
          id = (r - 1) * 9 + (c + 1)
          self.cell(id).set_solution(rows[r][c]) unless rows[r][c] == 0
        end
      end
    end

    def add_board_row(row, row_id)
      id = (row_id * 9) - 8
      (0..8).to_a.each do |i|
        self.cell(id).set_solution(row[i]) unless row[i] == 0
        id += 1
      end
    end

  ###################################################################
  ###### METHODS TO RETRIEVE SPECIFIC COLLECTIONS ON THE BOARD ######
  ###################################################################

  # row, col and block methods need to be modified so a new Collection
  # is not created each time a row, column or block is modified.
  # Potential solution would be to have an instance variable for each
  # unique row, column and block. These methods would then just return
  # the correct collection.

    def row(id)
    # Single cell ID as an arg and returns entire row the cell is part of.
      Collection.new.tap do |row|
        row_id = self.cell(id).row_head_id
        (row_id..row_id + 8).to_a.each { |id| row.add_cell(self.cell(id)) }
      end
    end

    def col(id)
    # Single cell ID as an arg and returns entire column the cell is part of.
      Collection.new.tap do |col|
        col_id = self.cell(id).col_head_id
        col_ids = Array.new(9, col_id).each_with_index.map { |a, i| a = a + 9 * i }
        col_ids.each { |id| col.add_cell(self.cell(id)) }
      end
    end

    def block(id)
    # Single cell ID as an arg and returns entire block the cell is part of.
      Collection.new.tap do |block|
        block_ids = self.cell(id).block
        block_ids.each { |block_id| block.add_cell(self.cell(block_id)) }
      end
    end

    def row_by_row_id(id)
    # Row ID as an arg and returns entire row.
    # i.e. Row ID 1 includes cells with IDs 1..9
      self.row(id * 9 - 8)
    end

    def col_by_col_id(id)
    # Column ID as an arg and returns entire row.
    # i.e. Column ID 1 includes cells [1,10,19,28,36,45,54,63,72]
      self.col( id % 9 == 0 ? 9 : ( id % 9 ) )
    end

    def block_by_block_id(id)
    # Block ID as an arg and returns entire row.
    # i.e. Block ID 1 includes cells [1,2,3,10,11,12,19,20,21]
      blocks = Cell.new(1).populate_blocks
      self.block(blocks[id][1])
    end

    def board_errors?
    # Checks all rows, columns and blocks for duplicate solutions in
    # any one collection.
      (1..9).to_a.each do |id|
        return true if self.row_by_row_id(id).errors? ||
                       self.col_by_col_id(id).errors? ||
                       self.block_by_block_id(id).errors?
      end
      false
    end

    def blank_cells?
    # Returns if there are any cells yet to be populated with a solution.
      (1..9).to_a.each do |i|
        row = self.row_by_row_id(i)
        return true if row.solutions.length < 9
      end
      return false
    end

    def solved?
    # Checks whether puzzle has been solved.  Only checks for the solution
    # once all cells have been populated.
      if self.blank_cells?
        puts "There are still blank cells on the board."
        return false
      elsif self.board_errors?
        puts "Sorry.  There are some errors on the board."
      else
        (1..9).to_a.each do |i|
          break unless self.row_by_row_id(i).check_solutions ||
                       self.col_by_col_id(i).check_solutions ||
                       self.block_by_block_id(i).check_solutions
        end
        self.print_board
        return true
      end
    end

    def print_board
      print " ___" * 9 << "\n"

      self.cells.each_with_index do |cell, index|
        print "|" if index % 9 == 0
        cell.print_cell
        print "\n" if (index + 1) % 9 == 0
      end
    end

  ###################################################################
  ###################### THE SOLVING ALGORITHM ######################
  ###################################################################

    def solve(itr=1)
    # Iterates through array of unsolved cells until solved or through 10 iterations.
    # Calls solver methods for each collection each unsolved cell is a part of.
    # Tests for a correct solution once all cells are populated.
      if itr == 11
        puts "I couldn't solve it.  This must be a tough one."
      else
        self.unsolved_ids.each do |cell_id|
          self.solve_row(cell_id)
          self.solve_block(cell_id)
          self.solve_col(cell_id)
        end
        self.blank_cells? ? self.solve(itr + 1) : self.solved?
      end
    end

    def unsolved_ids
    # Helper method for solve
    # Returns array of cell ids of cells that have yet to be solved.
    # Enables solver to iterate over only unsolved cells.
      unsolved_cell_ids = []
      @cells.each do |cell|
        unsolved_cell_ids.push(cell.id) if cell.solution.nil?
      end
      unsolved_cell_ids
    end

    def solve_row(id)
      self.row(id).solve_by_values(self.row(id).solutions)
      self.row(id).solve_by_solutions
      self.row(id).solve_by_doubles
      self.row(id).solve_by_triples
    end

    def solve_col(id)
      self.col(id).solve_by_values(self.col(id).solutions)
      self.col(id).solve_by_solutions
      self.col(id).solve_by_doubles
      self.col(id).solve_by_triples
    end

    def solve_block(id)
      self.block(id).solve_by_values(self.block(id).solutions)
      self.block(id).solve_by_solutions
      self.block(id).solve_by_doubles
      self.block(id).solve_by_triples
    end
  end
end