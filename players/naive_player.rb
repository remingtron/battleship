$:.unshift File.expand_path("../../data", __FILE__)

require 'sample_boards'

class NaivePlayer
  def name
    "Naive Player"
  end

  def new_game
    Battleship::SAMPLE_BOARDS[rand(Battleship::SAMPLE_BOARDS.length)]
  end

  def take_turn(state, ships_remaining)
    [rand(10), rand(10)]
  end
end
