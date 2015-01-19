class AddTableForTotalsFromPlayers < ActiveRecord::Migration
 	def change
 		create_table :skater_stat_totals do |t|
 			t.integer :player_id
 			t.integer :goals
 			t.integer :assists
 			t.integer :shots
 			t.integer :pim
 			t.integer :pm
 			t.timestamps
 		end
 	end
end
