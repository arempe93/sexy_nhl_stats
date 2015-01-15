# == Schema Information
#
# Table name: games
#
#  id              :integer          not null, primary key
#  nhl_id          :integer
#  game_time       :datetime
#  home_team_id    :integer
#  home_team_score :integer
#  away_team_id    :integer
#  away_team_score :integer
#  decision        :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class Game < ActiveRecord::Base

	# Callbacks

	# Validations

	# Relationships
	belongs_to :home_team, class_name: 'Team', foreign_key: 'home_team_id'
	belongs_to :away_team, class_name: 'Team', foreign_key: 'away_team_id'

	# Functions
	def winner
		home_team_score > away_team_score ? home_team : away_team
	end

	def home?(team)
		team.id == home_team_id
	end

	def opponent(team)
		team.id == home_team_id ? away_team : home_team
	end

	def opponent_score(team)
		team.id == home_team_id ? away_team_score : home_team_score
	end

	def home_team_stats
		TeamStat.find_by game_id: id, team_id: home_team_id
	end

	def away_team_stats
		TeamStat.find_by game_id: id, team_id: away_team_id
	end

	# Class Functions
	def self.all_played_games
		Game.all.where('decision is not null')
	end

	def self.unstored_games
		Game.all.where("home_team_score is null AND date_trunc('day', game_time) < '#{Date.today}'").order(:nhl_id)
	end
end