require './keypress.rb'
# top left board corner is [0,0]
class Board
	include Enumerable


	INITIAL_NUM_NON_EMPTY = 2

	attr_reader :size, :tiles

	def initialize(size=4)
		@size = size
		@tiles = []
		size.times do |r|
			@tiles << []
			size.times do |c|
				@tiles[r] << Tile.new(r, c)
			end
		end
		set_initial_state
	end
	

	def each &block
		@tiles.each do |row|
			row.each do |tile|
				block.call(tile)
			end
		end
	end

	def to_s
		str = " _______ _______ _______ _______ \n|       |       |       |       |\n"
		@tiles.each do |row|
			str += "|   "
			row.each do |tile|
				str += "#{tile.empty? ? " " : tile}   |   "
			end
			str += "\n|_______|_______|_______|_______|\n|       |       |       |       |\n"
		end
		str += "\n"
	end	

	# def can_move_into?(tile, nr, nc)
	# 	[nr, nc].all? { |n| 0 <= n && n < @size } && (@tiles[nr][nc].empty? || can_merge?(tile, @tiles[nr][nc]) )
	# end

	def assign_empty_tile
		random_empty_tile.set rand > 0.5 ? 1 : 2
	end

	private
		def set_initial_state(non_empty=INITIAL_NUM_NON_EMPTY)
			non_empty.times { assign_empty_tile }
		end


		def random_empty_tile
			begin
				r = rand(4)
				c = rand(4)

			end while !@tiles[r][c].empty?
			@tiles[r][c]
		end

		# def can_merge?(tile, other_tile)
		# 	tile.val == other_tile.val
		# end

end




class Tile 
	attr_reader :val, :row, :column
	attr_accessor :is_alreday_merged
	def initialize(r,c)
		@row, @column = r, c 
		@val = 0
	end

	def location
		[r, c]
	end
	
	def to_s
		@val.to_s
	end

	def empty?
		@val == 0
	end

	def set(v)
		@val = v
	end

	def set_empty
		@val = 0
	end

	def ==(other)
		@row == other.row && @column == other.column
	end

end

class Game
	WIN_TILE = 11

	CMDS = [:up, :down, :left, :right]
	# top left board corner is [0,0]
	CMD_DELTA = {
		up: [-1, 0],
		down: [1, 0],
		left: [0, -1],
		right: [0, 1]
	}

	attr_reader :board

	def initialize
		@board = Board.new
	end


	def play
		puts @board
		c = read_key
		while c != 'q' do			
			if is_legal_command?(c) 
				move(c) 
				@board.assign_empty_tile
			end
			puts @board
			exit(0) if win_or_lose?
			c = read_key
		end
	end

	def play_single(command)
		move(command) 
		@board.assign_empty_tile
	end

	def simulate_single(command)
		move(command) 
	end

	def possible_commands
		CMDS.select{ |c| is_legal_command?(c)}
	end

	def win_or_lose?
		win? || lose?
		# if win? 
		# 	# puts "\n\n\nWin!\n\n\n"
		# 	# exit(0)
		# elsif lose?
		# 	# puts "\n\n\nLose...\n\n\n"
		# 	# exit(0)
		# end
	end

	def win?
		@board.any? { |tile| tile.val ==  WIN_TILE }
	end

	# TODO: merge should be considered
	def lose?
		!CMDS.any? { |c| is_legal_command?(c) }
	end

	private
		# TODO: merge is also legal!
		def is_legal_command?(c)
			
			CMDS.include?(c) && @board.any? do |tile| 
				d = CMD_DELTA[c]
				nr = tile.row + d[0]
				nc =  tile.column + d[1]
				can_move_into?(tile,nr, nc) 
			end
		end

		ITR = {
			left: lambda { |board, r,c| board.tiles[r][c] },
			right: lambda { |board, r,c| board.tiles[r][board.size - c - 1] },
			up: lambda { |board, r,c| board.tiles[c][r] },
			down: lambda { |board, r,c| board.tiles[board.size - c - 1][r] }
		}
	
		def move(direction)
			d = CMD_DELTA[direction]
			@board.each{ |tile| tile.is_alreday_merged = false }
			@board.tiles.each_with_index do |row, r|
				row.each_with_index do |tile, c|
					tile = ITR[direction].call(@board, r, c)
					next if tile.empty?
					target_tile = @board.tiles[tile.row][tile.column]
					while can_move_into?(tile, target_tile.row + d[0], target_tile.column + d[1])
						target_tile = @board.tiles[target_tile.row + d[0]][target_tile.column + d[1]]
					end

					if tile != target_tile
						merge_factor = factor_for_moving(tile, target_tile)
						target_tile.is_alreday_merged = true if target_tile.val == tile.val
						target_tile.set(tile.val + merge_factor)
						tile.set_empty
					end
				end
			end
		end


		def factor_for_moving(tile, dest_tile)
			tile.val == dest_tile.val ? 1 : 0
		end


		def can_move_into?(tile, nr, nc)
			[nr, nc].all? { |n| 0 <= n && n < @board.size } && (@board.tiles[nr][nc].empty? || can_merge?(tile, @board.tiles[nr][nc]) )
		end


		def can_merge?(tile, other_tile)
			tile.val == other_tile.val && other_tile.is_alreday_merged == false
		end



end



# g = Game.new
# g.play


