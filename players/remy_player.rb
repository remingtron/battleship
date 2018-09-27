$:.unshift File.expand_path("../../data", __FILE__)

require 'sample_boards'

class RemyPlayer 
    def name
      "Remy"
    end

    def initialize
      @plays = (0...10).map { |x| ((x%2)...10).step(2).map { |y| [x,y] } }.flatten(1)
    end
  
    def new_game
      Battleship::SAMPLE_BOARDS[rand(Battleship::SAMPLE_BOARDS.length)]
    end
  
    def take_turn(state, ships_remaining)
      #surround any non-surrounded hits
      all_locations = (0...10).map {|x| (0...10).map { |y| [x,y]}}.flatten(1)
      all_locations.select {|l| state[l[1]][l[0]] == :hit}.each do |hit|
        # File.open('/tmp/foo', 'w') {|f| f.write(state[hit[1]][-1]) }
        return [hit[0] - 1, hit[1]] if is_valid_unknown([hit[0] - 1, hit[1]], state)
        return [hit[0], hit[1] + 1] if is_valid_unknown([hit[0], hit[1] + 1], state)
        return [hit[0] + 1, hit[1]] if is_valid_unknown([hit[0] + 1, hit[1]], state)
        return [hit[0], hit[1] - 1] if is_valid_unknown([hit[0], hit[1] - 1], state)
      end

      #random search
      while @plays.length > 0 do
        move = @plays.delete_at(rand(@plays.length))
        return move if state[move[1]][move[0]] == :unknown
      end

      return [0,0] #should never get here, but don't want to explode
    end

    def is_valid_unknown(candidate, state)
      candidate[0] >= 0 && candidate[0] <= 9 && candidate[1] >= 0 && candidate[1] <= 9 && state[candidate[1]][candidate[0]] == :unknown
    end
  end
  