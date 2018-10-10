$:.unshift File.expand_path("../../data", __FILE__)

require 'sample_boards'

class RemyPlayer 
    def name
      "Remy"
    end

    def initialize
      @plays = (0...10).map { |x| ((x%2)...10).step(2).map { |y| [x,y] } }.flatten(1)
      @sunk_locations = []
      @backup_plays = []
    end
  
    def new_game
      Battleship::SAMPLE_BOARDS[rand(Battleship::SAMPLE_BOARDS.length)]
    end
  
    def take_turn(state, ships_remaining)
      begin
        log(state[@last_shot[1]][@last_shot[0]]) if @last_shot
        prior_ships_remaining = @ships_remaining || [5,4,3,3,2]
        @ships_remaining = ships_remaining

        log(@ships_remaining)
        log(prior_ships_remaining)

        check_if_sank_ship(prior_ships_remaining)
        @last_shot, @direction = determine_shot(state, ships_remaining)

        log(@last_shot)
        log(@direction)
        return @last_shot
      rescue Exception => ex
        log("error: " + ex.message)
        log(ex.backtrace)
      end
    end

    def check_if_sank_ship(prior_ships_remaining)
      if prior_ships_remaining.size != @ships_remaining.size
        log('sank a ship!')
        first_different_index = (0...prior_ships_remaining.size).select {|i| prior_ships_remaining[i] != @ships_remaining[i]}.first
        sunk_ship_length = prior_ships_remaining[first_different_index]

        @sunk_locations += (0...sunk_ship_length).map {|x| move_direction(@last_shot, opposite_direction(@direction), x)}
        log(@sunk_locations)

        @last_shot = @direction = nil
      end
    end

    def log(message)
      if true
        File.open('/tmp/foo', 'a') do |file|
          file.write(message)
          file.write("\n")
        end
      end
    end

    def determine_shot(state, ships_remaining)
      #currently tracking a ship
      if @last_shot != nil && @direction != :none

        #continue in same direction if last shot was a hit
        if state[@last_shot[1]][@last_shot[0]] == :hit && is_valid_unknown(move_direction(@last_shot, @direction), state)
          return [move_direction(@last_shot, @direction), @direction]
        end
        
        #go in reverse direction if 
        # (a) last shot was a hit and can't continue that direction or 
        # (b) if last shot was a miss but two back was a hit
        back_two_in_other_dir = move_direction(@last_shot, opposite_direction(@direction), 2)
        if state[@last_shot[1]][@last_shot[0]] == :hit || (is_valid_position(back_two_in_other_dir) && state[back_two_in_other_dir[1]][back_two_in_other_dir[0]] == :hit)
          candidate = move_direction(@last_shot, opposite_direction(@direction))
          while is_valid_position(candidate)
            return [candidate, opposite_direction(@direction)] if is_valid_unknown(candidate, state)
            break if state[candidate[1]][candidate[0]] == :miss
            candidate = move_direction(candidate, opposite_direction(@direction))
          end
        end
      end

      #surround any non-surrounded hits
      all_locations = (0...10).map {|x| (0...10).map { |y| [x,y]}}.flatten(1)
      all_locations.select {|l| state[l[1]][l[0]] == :hit && !@sunk_locations.include?(l)}.each do |hit|
        [:left, :down, :right, :up].each do |dir|
          return [move_direction(hit, dir), dir] if is_valid_unknown(move_direction(hit, dir), state)
        end
      end

      #random search not around ships
      while @plays.length > 0 do
        move = @plays.delete_at(rand(@plays.length))
        return [move, :none] if state[move[1]][move[0]] == :unknown && surrounded_by_unknowns(move, state)
        @backup_plays << move if state[move[1]][move[0]] == :unknown
      end

      #remaining random search
      while @backup_plays.length > 0 do
        move = @backup_plays.delete_at(rand(@backup_plays.length))
        return [move, :none] if state[move[1]][move[0]] == :unknown
      end

      return [[0,0], :none] #should never get here, but don't want to explode
    end

    def surrounded_by_unknowns(move, state)
      return [:left, :right, :up, :down].map {|dir| move_direction(move, dir)}.select {|move| is_valid_position(move)}.all? {|move| is_valid_unknown(move, state)}
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

    def opposite_direction(direction)
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
      is_valid_position(candidate) && state[candidate[1]][candidate[0]] == :unknown
    end

    def is_valid_position(candidate)
      candidate[0] >= 0 && candidate[0] <= 9 && candidate[1] >= 0 && candidate[1] <= 9
    end
  end
  