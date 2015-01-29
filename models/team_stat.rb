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
#  penalties  :string
#  created_at :datetime
#  updated_at :datetime
#  goals      :integer
#  winner     :boolean
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
		percentage = numbers.first.to_f / numbers.last.to_f

		percentage.nan? ? 0.00 : percentage
	end

	def net_posession
		takeaways - giveaways
	end

	# Class Functions
	def self.last_ten(team)
		last_games team, 10
	end

	def self.last_games(team, n = 82)
		last_id = where(team_id: team.id).last(n).first.id

		{
			wins: joins(:game).where("team_id = #{team.id} AND team_stats.id >= #{last_id} AND winner = true").count,
			losses: joins(:game).where("team_id = #{team.id} AND team_stats.id >= #{last_id} AND winner = false AND decision = 'F'").count,
			ot: joins(:game).where("team_id = #{team.id} AND team_stats.id >= #{last_id} AND winner = false AND decision = 'OT'").count,
			so: joins(:game).where("team_id = #{team.id} AND team_stats.id >= #{last_id} AND winner = false AND decision = 'SO'").count
		}
	end

	def self.last_ten_stats(team)
		last_games_stats team, 10
	end

	def self.last_games_stats(team, n = 82)
		last_id = where(team_id: team.id).last(n).first.id

		totals = connection.execute("SELECT SUM(goals) AS goals, SUM(shots) AS shots, SUM(blocks) AS blocks, SUM(pim) AS pim, SUM(hits) AS hits, SUM(fow) AS fow, SUM(giveaways) AS giveaways, SUM(takeaways) AS takeaways " +
			"FROM team_stats WHERE team_id = #{team.id} AND id >= #{last_id} LIMIT #{n};")

		totals = totals.first.symbolize_keys

		# convert string values to integer
		totals.merge(totals) { |k, v| v.to_i }

		power_plays = 0
		capitalized = 0
		goals_against = 0
		where(team_id: team.id).last(n).each do |stat|
			pp = stat.penalties.split '/'

			capitalized += pp.first.to_i
			power_plays += pp.last.to_i
			goals_against += stat.game.opponent_score team
		end

		totals[:power_plays] = power_plays
		totals[:capitalized_pp] = capitalized
		totals[:penalty_percentage] = capitalized.to_f / power_plays
		totals[:goals_against] = goals_against

		totals
	end

	def self.over_time(options = {})

		attrib = options[:attrib]
		team = Team.find options[:team_id]

		start_game = options[:start_game] || 0
		end_game = options[:end_game] || team.all_played_games.last.id

		data = []
		count = 0
		self.all.where("team_id = #{team.id} AND game_id >= #{start_game} AND game_id <= #{end_game}").order(:game_id).each do |stats|

			count += stats.attributes[attrib].to_i
			data << [stats.game_id, count]
		end

		data
	end
end
