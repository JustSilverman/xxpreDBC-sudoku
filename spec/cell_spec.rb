require_relative '../lib/sudoku/cell.rb'
require 'minitest/autorun'

module Sudoku

  describe Cell do
    before do
      @cell1 = Cell.new(1)
      @cell2 = Cell.new(35)
    end

    it "must be a Cell" do
      @cell1.must_be_instance_of(Cell)
    end

    it "must have an id" do
      @cell1.id.must_equal 1
    end

    it "must be able to be solved" do
      @cell1.set_solution(3)
      @cell1.solution.must_equal 3
      @cell1.values.length.must_equal 1
    end

    it "must be able to update its values" do
      @cell1.update_cell_val([1,2,3,4,5])
      @cell1.values.must_equal [6,7,8,9]
    end

    it "must be able to update its values for doubles" do
      @cell1.update_cell_val([1,2,3,4,5,6,7])
      @cell1.update_cell_val([8,9])
      @cell1.values.must_equal [8,9]
    end

    it "must be able to identify triples" do
      @cell1.update_cell_val([1,2,3,4,5,6,7])
      @cell1.is_a_triple?([7,8,9]).must_equal true

      @cell2.update_cell_val([1,2,3,4,5])
      @cell2.is_a_triple?([7,8,9]).must_equal false
    end

    it "must be able to update values for triples" do
      @cell1.update_cell_val([1,2,3,4,5])
      @cell1.update_cell_triples([7,8,9])
      @cell1.values.must_equal [6]

      @cell2.update_cell_val([1,2,3,4,5,6])
      @cell2.update_cell_triples([7,8,9])
      @cell2.values.must_equal [7,8,9]
    end

    it "must return the correct row head ID" do
      @cell1.row_head_id.must_equal 1
      @cell2.row_head_id.must_equal 28
    end

    it "must return the correct column head ID" do
      @cell1.col_head_id.must_equal 1
      @cell2.col_head_id.must_equal 8
    end

    it "must return the correct block" do
      @cell1.block.must_equal [1,2,3,10,11,12,19,20,21]
      @cell2.block.must_equal [34,35,36,43,44,45,52,53,54]
    end
  end
end