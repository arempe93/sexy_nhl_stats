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
		(saves.to_f / shots_faced.to_f * 100).round(2)
	end

	def goals_against_average
		time = (toi.hour.to_f * 60) + toi.min.to_f + (toi.sec.to_f / 60)
		((goals_against.to_f / time) * 60).round(2)
	end

	def time_on_ice
		toi.hour == 1 ? "#{format('%02d', toi.min + 60)}:#{format('%02d', toi.sec)}" : "#{format('%02d', toi.min)}:#{format('%02d', toi.sec)}"
	end

	def opponent
		game = Game.find(game_id)
		opp = (team_id == game.home_team_id ? Team.find(game.away_team_id) : Team.find(game.home_team_id))
		opp.abbv
	end
end
