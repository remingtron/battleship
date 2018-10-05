$:.unshift File.expand_path("../../data", __FILE__)

require 'sample_boards'

class RemyPlayer 
    def name
      "Remy"
    end

    def initialize
      @plays = (0...10).map { |x| ((x%2)...10).step(2).map { |y| [x,y] } }.flatten(1)
      @sunk_locations = []
    end
  
    def new_game
      Battleship::SAMPLE_BOARDS[rand(Battleship::SAMPLE_BOARDS.length)]
    end
  
    def take_turn(state, ships_remaining)
      prior_ships_remaining = @ships_remaining || [5,4,3,3,2]
      @ships_remaining = ships_remaining

      if prior_ships_remaining.size != @ships_remaining.size
        first_different_index = (0...@ships_remaining.size).select {|i| prior_ships_remaining[i] != @ships_remaining[i]}.first
        sunk_ship_length = prior_ships_remaining[first_different_index]

        @sunk_locations += (0...sunk_ship_length).map {|x| move_direction(@last_shot, opposite_direction(@direction), x)}

        @last_shot = @direction = nil
      end

      @last_shot, @direction = determine_shot(state, ships_remaining)
      return @last_shot
    end

    def determine_shot(state, ships_remaining)
      
      if @last_shot != nil && @direction != nil
        if state[@last_shot[1]][@last_shot[0]] == :hit && is_valid_unknown(move_direction(@last_shot, @direction), state)
          return [move_direction(@last_shot, @direction), @direction]
        end
        
        # if state[@last_shot[1]][@last_shot[0]] == :miss
        #   return move_direction(@last_shot, @direction)
        # end

      end

      #surround any non-surrounded hits
      all_locations = (0...10).map {|x| (0...10).map { |y| [x,y]}}.flatten(1)
      all_locations.select {|l| state[l[1]][l[0]] == :hit && !@sunk_locations.include?(l)}.each do |hit|
        [:left, :down, :right, :up].each do |dir|
          return [move_direction(hit, dir), dir] if is_valid_unknown(move_direction(hit, dir), state)
        end
      end

      #random search
      while @plays.length > 0 do
        move = @plays.delete_at(rand(@plays.length))
        return move if state[move[1]][move[0]] == :unknown
      end

      return [0,0] #should never get here, but don't want to explode
    end

    def move_direction(location, direction, distance = 1)
      case direction
      when :left
        return [location[0] - distance, location[1]]
      when :right
        return [location[0] + distance, location[1]]
      when :up
        return [location[0], location[1] - distance]
      when :down
        return [location[0], location[1] + distance]
      end
    end

    def opposite_direction
      case direction
      when :left
        return :right
      when :right
        return :left
      when :up
        return :down
      when :down
        return :up
      end
    end

    def is_valid_unknown(candidate, state)
      candidate[0] >= 0 && candidate[0] <= 9 && candidate[1] >= 0 && candidate[1] <= 9 && state[candidate[1]][candidate[0]] == :unknown
    end
  end
  