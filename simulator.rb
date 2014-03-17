require './solver'
NUM_OF_SIMULATIONS = 100

res_str = ""

# solver = D2.new
[ RandomSolver, D1, D2, D3, NeverGoesUp, OneMoveAhead ].each do |solver_class|
# [ TwoMovesAhead ].each do |solver_class|
# [ NeverGoesUp ].each do |solver_class|
	solver = solver_class.new
	n_wins, n_loses = 0, 0
	max_tiles = []
	NUM_OF_SIMULATIONS.times do 
		solver.game = Game.new
		NUM_OF_SIMULATIONS == 1 ? solver.solve_to_file!("#{solver_class}.log") : solver.solve!

		# solver.solve_to_file!("#{solver_class}.log") if NUM_OF_SIMULATIONS == 1
		if solver.won?
			n_wins += 1
		elsif solver.lost?
			n_loses += 1
		end
		max_tiles << solver.game.board.max_by{|t| t.val}.val
	end
	max_avg_tile = max_tiles.inject{ |sum, el| sum + el }.to_f / max_tiles.size
	res_str += "#{solver.class}\nWON: #{n_wins}\nLOST: #{n_loses}\nHIGHEST TILE: #{max_tiles.max}\nAVERAGE HIGHEST TILE: #{max_avg_tile}\n\n"
end
puts res_str