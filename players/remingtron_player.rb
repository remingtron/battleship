class RemingtronPlayer

  def initialize
    @all_guesses = []
  end

  def name
    "remingtron"
  end

  def new_game
    [
      [1, 1, 5, :down],
      [3, 3, 4, :across],
      [6, 7, 3, :down],
      [9, 0, 3, :down],
      [0, 8, 2, :across]
    ]
  end

  def take_turn(state, ships_remaining)
    candidates = []
    (0...10).each do |x|
      (0...10).each do |y|
        candidates << [x, y]
      end
    end
    current_guess = candidates.select {|entry| state[entry[1]][entry[0]] == :unknown}.sample.sample
    puts "Current guess: " + current_guess.inspect
    @all_guesses << current_guess
    puts "All guesses: " + @all_guesses.sort{|x,y| x[0] <=> y[0]}.inspect
    current_guess
  end
end
