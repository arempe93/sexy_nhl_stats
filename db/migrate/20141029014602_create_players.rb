class CreatePlayers < ActiveRecord::Migration
	def change
		create_table :players do |t|
			t.integer :nhl_id
			t.references :team
			t.string :name
			t.integer :sweater
			t.string :player_type
		end
	end
end