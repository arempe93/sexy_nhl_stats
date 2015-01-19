class DropTotalsFromPlayers < ActiveRecord::Migration
  def change
  	remove_column :players, :goals
  	remove_column :players, :assists
  	remove_column :players, :pim
  	remove_column :players, :pm
  	remove_column :players, :shots
  end
end
