# == Schema Information
#
# Table name: teams
#
#  id         :integer          not null, primary key
#  nhl_id     :integer
#  city       :string(255)
#  name       :string(255)
#  abbv       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  conference :string(255)
#  division   :string(255)
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

	def wins
		wins = 0
		all_played_games.each do |game|
			wins += 1 if game.winner.id == id
		end
		wins
	end

	def losses
		losses = 0
		all_played_games.each do |game|
			losses += 1 if game.winner.id != id and game.decision == 'F'
		end
		losses
	end

	def ot
		ot = 0
		all_played_games.each do |game|
			ot += 1 if game.winner.id != id and (game.decision == 'OT' or game.decision == 'SO') 
		end
		ot
	end

	def points
		wins * 2 + ot
	end

	def logo_name
		logo = name.gsub /\s/, ''

		(city == 'Toronto' || city == 'Tampa Bay') ? logo + '_dark' : logo
	end

	def light_logo_name
		name.gsub /\s/, ''
	end

	# Class Functions
	def self.search(query)
		Team.find_by(abbv: query) || Team.find_by(name: query)
	end
end
