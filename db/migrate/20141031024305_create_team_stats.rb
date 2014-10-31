class CreateTeamStats < ActiveRecord::Migration
	def change
		create_table :team_stats do |t|
			t.integer :team_id
			t.integer :game_id
			t.integer :shots
			t.integer :blocks
			t.integer :pim
			t.integer :hits
			t.integer :fow
			t.integer :takeaways
			t.integer :giveaways
			t.string :penalties
		end
	end
end
