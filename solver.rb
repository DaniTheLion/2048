require './2048.rb'
class Solver
	attr_accessor :game

	def initialize
		@game = Game.new
	end

	def solve!
		# puts @game.board
		# puts pick_move
		while !@game.win_or_lose?
			# puts @game.board
			# puts pick_move
			@game.play_single(pick_move)
		end
	end

	def solve_to_file!(filename)
		output = File.open( "./game_logs/#{filename}","w" )
		game_log = ""
		while !@game.win_or_lose?
			game_log << @game.board.to_s
			move = pick_move
			game_log << "#{move}\n\n"
			@game.play_single(move)
		end
		output << game_log
		output.close
	end

	def won?
		@game.win?
	end

	def lost?
		@game.lose?
	end

	private
		def pick_move
			raise "Not Impemented!"
		end
end

# Always chooses randomly
class RandomSolver < Solver
	private
		def pick_move
			@game.possible_commands.sample	
		end
end

# Chosses the move that maximizes a function of the board after the move.
# Evaludate function is board sum (and it sucks since it prefers not to merge.)
class D1 < Solver
	private
		# sum of all tiles
		def evaluate(game)
			game.board.inject(0) { |sum, tile| sum + tile.val}
		end

		def pick_move
			moves_n_scores = @game.possible_commands.collect do |move|
				game_copy = Marshal::load(Marshal.dump(@game))
				game_copy.simulate_single(move)
				[move, evaluate(game_copy)]
			end
			max = moves_n_scores.max_by{ |k,v| v }[1]
			moves_n_scores.select{ |k,v| v == max }.map{|k,v| k }.sample
		end
end


class D2 < D1
	private
		# sum of all tiles, scores higher for more empty tiles and thus choosing to merge
		def evaluate(game)
			sum_of_tiles = game.board.inject(0) { |sum, tile| sum + tile.val} 
			empty_tiles_factor = (game.board.select{|t| t.empty?}.count * 15) 
			sum_of_tiles + empty_tiles_factor
		end
end


# Evaluate function is a sum of all tiles, empty tile factor and a highest tile factor (thus choosing to merge
# hisgher rather than a few lower merges) 
class D3 < D1
	private
		# sum of all tiles, scores higher for more empty tiles and thus choosing to merge
		def evaluate(game)
			sum_of_tiles = game.board.inject(0) { |sum, tile| sum + tile.val} 
			empty_tiles_factor = (game.board.select{|t| t.empty?}.count * 15) 
			max_tile = game.board.max_by { |tile| tile.val}.val
			highest_tile_factor = max_tile * max_tile
			sum_of_tiles + empty_tiles_factor + highest_tile_factor
		end
end

# Does not go UP unless no other choice.
class NeverGoesUp < D1
	private
		def pick_move
			moves = (@game.possible_commands - [:up]).empty? ? @game.possible_commands : @game.possible_commands - [:up]
			moves_n_scores = moves.collect do |move|
				game_copy = Marshal::load(Marshal.dump(@game))
				game_copy.simulate_single(move)
				[move, evaluate(game_copy)]
			end
			max = moves_n_scores.max_by{ |k,v| v }[1]
			moves_n_scores.select{ |k,v| v == max }.map{|k,v| k }.sample
		end
		# sum of all tiles, scores higher for more empty tiles and thus choosing to merge
		def evaluate(game)
			sum_of_tiles = game.board.inject(0) { |sum, tile| sum + tile.val} 
			empty_tiles_factor = (game.board.select{|t| t.empty?}.count * 15) 
			max_tile = game.board.max_by { |tile| tile.val}.val
			highest_tile_factor = max_tile * max_tile 
			sum_of_tiles + empty_tiles_factor + highest_tile_factor
		end
end

# Maximizes board score two steps ahead
class OneMoveAhead < D1
	private

		def pick_move
			moves_n_scores = @game.possible_commands.collect do |move|
				game_copy = Marshal::load(Marshal.dump(@game))
				game_copy.simulate_single(move)
				next_move_scores = []
				game_copy.possible_commands.collect do |next_move|
					second_copy = Marshal::load(Marshal.dump(game_copy))
					second_copy.simulate_single(next_move)
					next_move_scores << evaluate(second_copy)
				end
				[move, next_move_scores.max]
			end
			max = moves_n_scores.max_by{ |k,v| v }[1]
			moves_n_scores.select{ |k,v| v == max }.map{|k,v| k }.sample
		end

		# sum of all tiles, scores higher for more empty tiles and thus choosing to merge
		def evaluate(game)
			sum_of_tiles = game.board.inject(0) { |sum, tile| sum + tile.val} 
			empty_tiles_factor = (game.board.select{|t| t.empty?}.count * 15) 
			max_tile = game.board.max_by { |tile| tile.val}.val
			highest_tile_factor = max_tile * max_tile * max_tile * max_tile
			sum_of_tiles + empty_tiles_factor + highest_tile_factor
		end
end


# s = D2.new
# s.solve!