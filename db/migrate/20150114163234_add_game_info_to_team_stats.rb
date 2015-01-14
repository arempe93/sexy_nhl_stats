class AddGameInfoToTeamStats < ActiveRecord::Migration
	def change
		add_column :team_stats, :goals, :integer
		add_column :team_stats, :winner, :boolean
	end
end
