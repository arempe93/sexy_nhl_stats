# == Schema Information
#
# Table name: teams
#
#  id         :integer          not null, primary key
#  nhl_id     :integer
#  city       :string
#  name       :string
#  abbv       :string
#  created_at :datetime
#  updated_at :datetime
#  conference :string
#  division   :string
#  wins       :integer          default("0")
#  losses     :integer          default("0")
#  ot         :integer          default("0")
#  row        :integer          default("0")
#

class Team < ActiveRecord::Base

	# Callbacks

	# Valiadations
	validates :nhl_id, presence: true, uniqueness: true
	validates :city, presence: true
	validates :name, presence: true
	validates :abbv, presence: true, uniqueness: true

	# Relationships
	has_many :players
	has_many :home_games, class_name: 'Game', foreign_key: 'home_team_id'
	has_many :away_games, class_name: 'Game', foreign_key: 'away_team_id'
	has_many :team_stats

	# Functions
	def all_games
		Game.all.where("home_team_id = #{id} or away_team_id = #{id}")
	end

	def all_played_games
		Game.all.where("decision is not null and (home_team_id = #{id} or away_team_id = #{id})")
	end

	def games_played
		all_played_games.count
	end

	def logo_name
		logo = name.gsub /\s/, ''

		(city == 'Toronto' || city == 'Tampa Bay') ? logo + '_dark' : logo
	end

	def light_logo_name
		name.gsub /\s/, ''
	end

	# Stat Functions
	def points
		wins * 2 + ot
	end

	# Chart Functions
	def points_over_time(options = {})
		start_game = options[:start_game] || 0
		end_game = options[:end_game] || all_played_games.last.id

		data = []
		points = 0
		team_stats.where("game_id >= #{start_game} AND game_id <= #{end_game}").order(:game_id).each do |stats|
			
			if stats.winner
				points += 2
			elsif not stats.winner and stats.game.decision != 'F'
				points += 1
			end

			data << [stats.game_id, points]
		end

		data
	end

	# Class Functions
	def self.search(query)
		Team.find_by(abbv: query) || Team.find_by(name: query)
	end
end
