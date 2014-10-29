class CreateGames < ActiveRecord::Migration
	def change
		create_table :games do |t|
			t.integer :nhl_id
			t.datetime :game_time
			t.integer :home_team_id
			t.integer :home_team_score
			t.integer :away_team_id
			t.integer :away_team_score
			t.string :decision
			t.timestamps
		end
	end
end
