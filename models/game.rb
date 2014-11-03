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

	def self.last(team, n = 1)
		
		games = Game.all.where "game_time < '#{(DateTime.now.midnight + 3.hours).strftime('%F %T %z')}' and (home_team_id = #{team.id} or away_team_id = #{team.id})"
		games.last n
	end
end