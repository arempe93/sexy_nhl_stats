class CreateGoalieStats < ActiveRecord::Migration
	def change
		create_table :goalie_stats do |t|
			t.references :game
			t.references :player
			t.references :team
			t.integer :shots_faced
			t.integer :saves
			t.integer :goals_against
			t.time :toi
			t.timestamps
		end
	end
end