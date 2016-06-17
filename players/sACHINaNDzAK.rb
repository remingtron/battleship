class StupidPlayer
  def name
    "Sachin and Zak Player"
  end

  def new_game
    [
        [1, 1, 5, :across],
        [2, 2, 4, :across],
        [3, 3, 3, :across],
        [7, 6, 3, :across],
        [1, 9, 2, :across]
    ]
  end

  def take_turn(state, ships_remaining)
    [rand(10), rand(10)]
  end
end
