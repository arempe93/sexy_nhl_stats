class AddRecordToTeams < ActiveRecord::Migration
  	def change
  		add_column :teams, :wins, :integer, :default => 0
  		add_column :teams, :losses, :integer, :default => 0
  		add_column :teams, :ot, :integer, :default => 0
  		add_column :teams, :row, :integer, :default => 0
  	end
end
