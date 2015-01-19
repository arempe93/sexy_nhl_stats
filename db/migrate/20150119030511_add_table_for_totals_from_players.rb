class AddTableForTotalsFromPlayers < ActiveRecord::Migration
 	def change
 		create_table :skater_stat_totals do |t|
 			t.integer :player_id
 			t.integer :goals, :default => 0
 			t.integer :assists, :default => 0
 			t.integer :shots, :default => 0
 			t.integer :pim, :default => 0
 			t.integer :pm, :default => 0
 			t.timestamps
 		end
 	end
end
