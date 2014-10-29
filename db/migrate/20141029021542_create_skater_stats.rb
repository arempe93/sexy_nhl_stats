class CreateSkaterStats < ActiveRecord::Migration
	def change
		create_table :skater_stats do |t|
			t.references :game
			t.references :player
			t.references :team
			t.integer :goals
			t.integer :assists
			t.integer :shots
			t.integer :pim
			t.integer :pm
			t.time :toi
			t.timestamps
		end
	end
end
