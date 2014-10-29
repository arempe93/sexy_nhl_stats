# == Schema Information
#
# Table name: skater_stats
#
#  id         :integer          not null, primary key
#  game_id    :integer
#  player_id  :integer
#  team_id    :integer
#  goals      :integer
#  assists    :integer
#  shots      :integer
#  pim        :integer
#  pm         :integer
#  toi        :time
#  created_at :datetime
#  updated_at :datetime
#

class SkaterStat < ActiveRecord::Base

	# Callbacks

	# Validations

	# Relationships
	belongs_to :game
	belongs_to :player
	belongs_to :team

	# Functions
	def points
		goals + assists
	end

	def shot_percentage
		goals.to_f / shots.to_f
	end
end