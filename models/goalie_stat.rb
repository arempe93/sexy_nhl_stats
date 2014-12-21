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
		if toi != nil
			time = toi.min.to_f + (toi.sec.to_f / 60)
			((goals_against.to_f / time) * 60).round(2)
		else
			0.0
		end
	end

	def time_on_ice
		if(toi != nil)
			toi.hour == 1 ? "#{toi.hour}:#{format('%02d', toi.min)}:#{format('%02d', toi.sec)}" : "#{format('%02d', toi.min)}:#{format('%02d', toi.sec)}"
		else
			"60:00"
		end
	end
end
