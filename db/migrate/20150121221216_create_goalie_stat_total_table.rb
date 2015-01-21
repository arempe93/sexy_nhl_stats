class CreateGoalieStatTotalTable < ActiveRecord::Migration
  	def change
 		create_table :goalie_stat_totals do |t|
 			t.integer :player_id
 			t.integer :shots_faced, 	:default => 0
 			t.integer :saves, 			:default => 0
 			t.integer :goals_against, 	:default => 0
 			t.integer :shutouts, 		:default => 0
 			t.integer :wins,			:default => 0
 			t.time 	  :toi, 			:default => Time.new(0)
 			t.timestamps
 		end
  	end
end
