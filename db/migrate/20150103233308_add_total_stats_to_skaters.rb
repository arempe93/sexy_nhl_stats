class AddTotalStatsToSkaters < ActiveRecord::Migration
  	def change
  		add_column :players, :goals, :integer, :default => 0
  		add_column :players, :assists, :integer, :default => 0
  		add_column :players, :pim, :integer, :default => 0
  		add_column :players, :pm, :integer, :default => 0
  		add_column :players, :shots, :integer, :default => 0
  	end
end
