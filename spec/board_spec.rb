require_relative '../lib/sudoku/board.rb'
require 'minitest/autorun'

module Sudoku

  describe Cell do
    before do
      @board = Board.new
      @blank_board = Board.new
      @solved_board = Board.new

      test_rows = {}
      test_rows[1] = [8,2,0,3,0,0,0,0,0]
      test_rows[2] = [0,1,4,0,0,9,0,0,0]
      test_rows[3] = [0,0,0,8,0,0,2,6,1]
      test_rows[4] = [0,6,0,2,0,0,4,0,0]
      test_rows[5] = [7,8,0,0,0,0,0,0,0]
      test_rows[6] = [0,0,0,5,9,0,0,0,0]
      test_rows[7] = [0,0,0,0,8,0,0,7,5]
      test_rows[8] = [0,0,0,4,3,6,0,2,0]
      test_rows[9] = [0,3,0,0,0,7,0,0,0]

      solved_rows = {}
      solved_rows[1] = [8,2,5,3,6,1,7,9,4]
      solved_rows[2] = [6,1,4,7,2,9,8,5,3]
      solved_rows[3] = [9,7,3,8,4,5,2,6,1]
      solved_rows[4] = [5,6,1,2,7,3,4,8,9]
      solved_rows[5] = [7,8,9,6,1,4,5,3,2]
      solved_rows[6] = [3,4,2,5,9,8,6,1,7]
      solved_rows[7] = [4,9,6,1,8,2,3,7,5]
      solved_rows[8] = [1,5,7,4,3,6,9,2,8]
      solved_rows[9] = [2,3,8,9,5,7,1,4,6]

      @board.populate_board test_rows
      @solved_board.populate_board solved_rows
    end

    it "should have 81 cells" do
      @board.cells.length.must_equal 81
    end

    it "should have IDs 1 - 81" do
      ids = []
      @board.cells.each {|c| ids << c.id}
      ids.sort.must_equal (1..81).to_a
    end

    it "should add row" do
      row = [0,1,4,0,0,9,0,0,0]
      @blank_board.add_board_row row, 1
      solutions = []
      @blank_board.row(1).cells.each {|c| solutions << c.solution}
      solutions.must_equal [nil,1,4,nil,nil,9,nil,nil,nil]
    end

    it "should retrieve row by cell id" do
      row = @board.row(10)
      solutions = []
      row.cells.each {|c| solutions << c.solution}
      solutions.must_equal [nil,1,4,nil,nil,9,nil,nil,nil]
    end

    it "should retrieve column by cell id" do
      column = @board.col(10)
      solutions = []
      column.cells.each {|c| solutions << c.solution}
      solutions.must_equal [8,nil,nil,nil,7,nil,nil,nil,nil]
    end

    it "should retrieve row by row id" do
      row = @board.row_by_row_id(3)
      solutions = []
      row.cells.each {|c| solutions << c.solution}
      solutions.must_equal [nil,nil,nil,8,nil,nil,2,6,1]
    end

    it "should retrieve column by column id" do
      column = @board.col_by_col_id(3)
      solutions = []
      column.cells.each {|c| solutions << c.solution}
      solutions.must_equal [nil,4,nil,nil,nil,nil,nil,nil,nil]
    end

    it "should retrieve block by block id" do
      block = @board.block_by_block_id(3)
      solutions = []
      block.cells.each {|c| solutions << c.solution}
      solutions.must_equal [nil,nil,nil,nil,nil,nil,2,6,1]
    end

    it "should detect board errors" do
      @board.cell(3).set_solution(2)
      @board.board_errors?.must_equal true
    end

    it "should detect a solved board" do
      @board.solved?.must_equal false
      @solved_board.solved?.must_equal true
    end

    it "should should be solved" do
      @board.solve
      @board.solved?.must_equal true
    end

    it "should return unsolved IDs" do
      @board.unsolved_ids.must_equal [3,5,6,7,8,9,10,13,14,16,17,18,19,20,21,23,24,28,30,32,33,35,36,39,40,41,42,43,44,45,46,47,48,51,52,53,54,55,56,57,58,60,61,64,65,66,70,72,73,75,76,77,79,80,81]
    end
  end
end