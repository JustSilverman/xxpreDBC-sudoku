require_relative 'collection'

module Sudoku
  class Board < Collection
  # Board represents 81 cells in a 9X9 square
  # Each board contains 9 rows, columns and blocks
  # Board can be represented by a two-dimensional hash of cells

    attr_accessor :cells, :rows, :solutions, :unsolved_cell_ids

    def initialize
    # Creates blank board. No cell contains a solution or any eliminated
    # possible solutions.
      @cells     = [].tap { |cells| (1..81).to_a.each{ |id| cells << Cell.new(id) } }
      @rows      = create_rows
      @cols      = create_cols
      @blocks    = create_blocks
      @solutions = []
    end

    def populate_board(rows)
    # Populates board with pre-populated two-dimensional hash
    # Blank cells are represented by 0's in the hash.
      (1..9).to_a.each do |r|
        (0..8).to_a.each do |c|
          id = (r - 1) * 9 + (c + 1)
          cell(id).set_solution(rows[r][c]) unless rows[r][c] == 0
        end
      end
    end

    def add_board_row(row, row_id)
      id = (row_id * 9) - 8
      (0..8).to_a.each do |i|
        cell(id).set_solution(row[i]) unless row[i] == 0
        id += 1
      end
    end

    def print_board
      print " ___" * 9 << "\n"

      cells.each_with_index do |cell, index|
        print "|" if index % 9 == 0
        cell.print_cell
        print "\n" if (index + 1) % 9 == 0
      end
    end

  ###################################################################
  ###### METHODS TO RETRIEVE SPECIFIC COLLECTIONS ON THE BOARD ######
  ###################################################################

    def row(id)
    # Single cell ID as an arg and returns entire row the cell is part of.
      @rows[cell(id).row_index]
    end

    def col(id)
    # Single cell ID as an arg and returns entire column the cell is part of.
      @cols[cell(id).col_index]
    end

    def block(id)
    # Single cell ID as an arg and returns entire block the cell is part of.
      @blocks[cell(id).block_index]
    end

  ###################################################################
  ###################### THE SOLVING ALGORITHM ######################
  ###################################################################

    def unsolved_ids
    # Helper method for solve
    # Returns array of cell ids of cells that have yet to be solved.
    # Enables solver to iterate over only unsolved cells.
      [].tap do |unsolved_cell_ids|
        @cells.each { |cell| unsolved_cell_ids.push(cell.id) if cell.solution.nil? }
      end
    end

    def blank_cells?
    # Returns if there are any cells yet to be populated with a solution.
      (1..9).to_a.each do |i|
        row = @rows[i - 1]
        return true if row.solutions.length < 9
      end
      return false
    end

    def board_errors?
    # Checks all rows, columns and blocks for duplicate solutions in
    # any one collection.
      (1..9).to_a.each do |id|
        return true if @rows[id - 1].errors? ||
                       @cols[id - 1].errors? ||
                       @blocks[id - 1].errors?
      end
      false
    end

    def solve(itr=1)
    # Iterates through array of unsolved cells until solved or through 10 iterations.
    # Calls solver methods for each collection each unsolved cell is a part of.
    # Tests for a correct solution once all cells are populated.
      if itr == 11
        puts "I couldn't solve it.  This must be a tough one."
      else
        unsolved_ids.each do |cell_id|
          solve_row(cell_id)
          solve_block(cell_id)
          solve_col(cell_id)
        end
        blank_cells? ? solve(itr + 1) : solved?
      end
    end

    def solved?
      if blank_cells?
        puts "There are still blank cells on the board."
        return false
      elsif board_errors?
        puts "Sorry.  There are some errors on the board."
      else
        (1..9).to_a.each do |i|
          break unless @rows[i - 1].check_solutions ||
                       @cols[i - 1].check_solutions ||
                       @blocks[i - 1].check_solutions
        end
        print_board
        return true
      end
    end

    private
    def create_rows
      9.times.map do |i|
        Collection.new.tap do |row|
          row_id = i * 9 + 1
          (row_id..row_id + 8).to_a.each { |id| row.add_cell(cell(id)) }
        end
      end
    end

    def create_cols
      9.times.map do |i|
        Collection.new.tap do |col|
          col_ids = Array.new(9, i + 1).each_with_index.map { |a, i| a = a + 9 * i }
          col_ids.each { |id| col.add_cell(cell(id)) }
        end
      end
    end

    def create_blocks
      9.times.map do |i|
        Collection.new.tap do |block|
          block_ids = cell(1).populate_blocks[i + 1]
          block_ids.each { |block_id| block.add_cell(cell(block_id)) }
        end
      end
    end

    def solve_row(id)
      row(id).solve_by_values(row(id).solutions)
      row(id).solve_by_solutions
      row(id).solve_by_doubles
      row(id).solve_by_triples
    end

    def solve_col(id)
      col(id).solve_by_values(col(id).solutions)
      col(id).solve_by_solutions
      col(id).solve_by_doubles
      col(id).solve_by_triples
    end

    def solve_block(id)
      block(id).solve_by_values(block(id).solutions)
      block(id).solve_by_solutions
      block(id).solve_by_doubles
      block(id).solve_by_triples
    end
  end
end