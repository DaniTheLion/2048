require './solver'
num_of_simulations = (ARGV[0] || 20).to_i

res_str = ""

# solver = D2.new
# [ RandomSolver, D1, D2, D3, NeverGoesUp, OneMoveAhead ].each do |strategy|
[ D4, PenaltyForOrphanTiles ].each do |strategy|
# [ NeverGoesUp ].each do |solver_class|
	solver = Solver.new(strategy)
	n_wins, n_loses = 0, 0
	max_tiles = []
	num_of_simulations.times do 
		solver.game = Game.new
		num_of_simulations == 1 ? solver.solve_to_file!("#{strategy}.log") : solver.solve!
		if solver.won?
			n_wins += 1
		elsif solver.lost?
			n_loses += 1
		end
		max_tiles << solver.game.board.max_by{|t| t.val}.val
	end
	max_avg_tile = max_tiles.inject{ |sum, el| sum + el }.to_f / max_tiles.size
	res_str += "#{solver}\nWON: #{n_wins}\nLOST: #{n_loses}\nHIGHEST TILE: #{max_tiles.max}\nAVERAGE HIGHEST TILE: #{max_avg_tile}\n\n"
end
puts res_str

# some changes