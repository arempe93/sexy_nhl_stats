class AddConferenceAndDivisionToTeam < ActiveRecord::Migration
	def change
		add_column :teams, :conference, :string
		add_column :teams, :division, :string
	end
end
