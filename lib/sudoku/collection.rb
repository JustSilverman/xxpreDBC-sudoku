require_relative 'cell'

module Sudoku
  class Collection
  # Collection represents any grouping of cells on a Sudoku board
  # This includes a row, column, block (1 of the nine 3X3 groupings of cells) or the board itself
  # Each collection is represented by an array of cells

    attr_accessor :cells, :solutions

    def initialize(cells=[])
      @cells = cells
      @solutions = []
    end

    def add_cell(cell)
      @cells << cell
    end

    def cell(id)
      @cells.each { |cell| return cell if cell.id == id }
    end

    def values
    # Returns an array of arrays of the remaining possible values for each cell in self
      [].tap do |values|
        @cells.each { |cell| values.push(cell.values) }
      end
    end

    def solutions
    # Updates and returns the @solutions array
    # It must be updated prior to being returned to capture
    # any cells that have been solved since the last update
      @cells.each do |cell|
        @solutions << cell.solution unless cell.solution.nil? || @solutions.include?(cell.solution)
      end
      @solutions
    end

    def check_solutions
      self.solutions.sort == (1..9).to_a
    end

    def errors?
    # Determines if there are any duplicate solutions in a collection
      sols = []
      @cells.each {|c| sols << c.solution unless c.solution.nil? }
      sols.uniq != sols
    end

  ####################################################################
  ############ FLEET OF SOLVER METHODS AND HELPER METHODS ############
  ####################################################################

  def solve_by_values(val)
    # Solves by removing possible solutions from a collection of cells.
    # Cells within the collection will be solved when only one possible solution reaains.
    @cells.each { |cell| cell.update_cell_val( val ) }
  end

    def solve_by_solutions
    # Solves by finding possible solutions that exist only once within a particular collection.
    # The cell where that unique possible solution exists is set to such unique solution.
      @cells.each do |cell|
        self.uniq_values.each { |u| cell.set_solution(u) if cell.values.include?(u) } if cell.solution.nil?
      end
    end

    def uniq_values
    # Helper method for solve_by_solutions
    # Finds and returns any remaining possible values in the collection that are only present in one cell.
      count_hash = {}
      values = self.values.flatten.sort.each do |value|
        count_hash[value] = count_hash[value].nil? ? 1 : (count_hash[value] + 1)
      end
      count_hash.delete_if { |key, value| value > 1 }.keys
    end

    def solve_by_doubles
      @cells.each { |cell| cell.update_cell_val(self.doubles) } if self.doubles
    end

    def doubles
    # Helper method for solve_by_doubles
    # Finds and returns any Doubles. Returned as hash with cell ID as key and possible values as hash values.
    # Doubles represent a situation in which two cells in a row, column or block
    # have the same two values as possible solutions.  This indicates that no other
    # cell in the collection could be either of those two values.
      doubles = {}
      @cells.each { |cell| doubles[cell.id] = cell.values if cell.values.length == 2 }

      if doubles.length >= 2
        doubles.each do |key, value|
          return value if doubles.dup.delete_if {|k, v| k == key }.has_value?(value)
        end
        nil
      end

    end

    def solve_by_triples
      @cells.each { |cell| cell.update_cell_triples(self.triples) unless self.triples.nil? }
    end

    def triples
    # Helper method for solve_by_triples
    # Finds and returns Triples. Returned as array of 3 possible values in Triple.
    # Triples represent 3 cells in one collection that do not contain
    # any other numbers other than the three possible values of those three cells
    # This indicates that no other cell in the collection could be any of those three values.
      unless self.triples_cells.nil?
        values = []
        self.combination_values.values.each do |val|
          values << val.flatten.uniq if val.flatten.uniq.length == 3
        end
        values.flatten
      end
    end

    def triples_cells
    # Helper method for solve_by_triples
    # Finds any cells that could potentially be part of a triple.
    # Triples must have 2 or 3 possible solutions remaining.
      t_cells = @cells.dup
      t_cells.keep_if {|c| c.values.length == 2 || c.values.length == 3}
      t_cells if t_cells.length >= 3
    end

    def combination_values
    # Helper method for solve_by_triples
    # Converts potential triplet combos into hash with the hash values
    # the values of each cell in each combination.
      unless self.triples_cells.nil?
        cells_array = self.triples_cells

        {}.tap do |triple_combos|
          self.potential_triplet_combos.values.each_with_index do |combo, i|
            triple_combos[i] = []
            combo.each {|index| triple_combos[i] << cells_array[index].values}
          end
        end
      end
    end

    def potential_triplet_combos
    # Helper method for solve_by_triples
    # Based on the number of potential triples cells, creates all 3 cell combinations
    # Returns a hash with the values an array representing the index of the t_cells array
    # i.e. If there are 5 triples_cells, this method would return all 10 3 cell combinations
      unless self.triples_cells.nil?
        length = self.triples_cells.length
        count = 1; a = 0; b = 1; c = 2

        {}.tap do |hash|
          loop do
            break if a == length - 1

            while c <= length - 1
              hash[count] = [a, b, c]
              count += 1; c += 1
            end

            if b == length - 1 && c == length
              a += 1; b = a + 1; c = a + 2
            else
              b += 1; c = b + 1
            end
          end
        end
      end
    end
  end
end