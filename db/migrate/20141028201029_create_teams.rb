class CreateTeams < ActiveRecord::Migration
	def change
		create_table :teams do |t|
			t.integer :nhl_id
			t.string :city
			t.string :name
			t.string :abbv
			t.timestamps
		end
	end
end