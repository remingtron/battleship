class SamirPlayer
  def name
    "Samir Player"
  end

  def new_game
    [
      [2, 2, 5, :across],
      [4, 7, 4, :across],
      [6, 5, 3, :across],
      [3, 3, 3, :across],
      [3, 6, 2, :across]
    ]
  end

  def take_turn(state, ships_remaining) 
    fire=false
    rowindex=0
    state.each do |row|
	rowindex=rowindex+1
	cellindex=0
	row.each do |cell|
		cellindex=cellindex+1
		if cell==:unknown
			puts [rowindex-1,cellindex-1].inspect
			return [cellindex-1,rowindex-1]
		end 
	end
    end
  end
end
