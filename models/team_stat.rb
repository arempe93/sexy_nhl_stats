# == Schema Information
#
# Table name: team_stats
#
#  id         :integer          not null, primary key
#  team_id    :integer
#  game_id    :integer
#  shots      :integer
#  blocks     :integer
#  pim        :integer
#  hits       :integer
#  fow        :integer
#  takeaways  :integer
#  giveaways  :integer
#  penalties  :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class TeamStat < ActiveRecord::Base

	# Callbacks

	# Validations

	# Relationships
	belongs_to :team
	belongs_to :game

	# Functions
	def penalty_percentage
		numbers = penalties.split '/'

		numbers.first.to_f / numbers.last.to_f
	end

	def net_posession
		takeaways - giveaways
	end

	# Class Functions
	def self.last_ten(team)
		last_games team, 10
	end

	def self.last_games(team, n = 200)
		last_id = where(team_id: team.id).last(n).first.id

		{
			wins: joins(:game).where("team_id = #{team.id} AND team_stats.id >= #{last_id} AND winner = true").count,
			losses: joins(:game).where("team_id = #{team.id} AND team_stats.id >= #{last_id} AND winner = false AND decision = 'F'").count,
			ot: joins(:game).where("team_id = #{team.id} AND team_stats.id >= #{last_id} AND winner = false AND decision = 'OT'").count,
			so: joins(:game).where("team_id = #{team.id} AND team_stats.id >= #{last_id} AND winner = false AND decision = 'SO'").count
		}
	end
end
