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
		(goals.to_f / shots.to_f).round(3)
	end

	def time_on_ice
		toi.hour == 1 ? "#{format('%02d', toi.min + 60)}:#{format('%02d', toi.sec)}" : "#{format('%02d', toi.min)}:#{format('%02d', toi.sec)}"
	end

	def penalty_minutes
		"#{pim}:00"
	end	

	def opponent
		game = Game.find(game_id)
		opp = (team_id == game.home_team_id ? Team.find(game.away_team_id) : Team.find(game.home_team_id))
		opp.abbv
	end
end