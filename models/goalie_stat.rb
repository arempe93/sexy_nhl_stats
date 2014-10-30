# == Schema Information
#
# Table name: goalie_stats
#
#  id            :integer          not null, primary key
#  game_id       :integer
#  player_id     :integer
#  team_id       :integer
#  shots_faced   :integer
#  saves         :integer
#  goals_against :integer
#  toi           :time
#  created_at    :datetime
#  updated_at    :datetime
#

class GoalieStat < ActiveRecord::Base

	# Callbacks

	# Validations

	# Relationships
	belongs_to :goalie, class_name: 'Player', foreign_key: 'player_id'
	belongs_to :game
	belongs_to :team

	# Functions
	def save_percentage
		shots_faced.to_f / saves.to_f
	end
end
