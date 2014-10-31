# == Schema Information
#
# Table name: players
#
#  id          :integer          not null, primary key
#  nhl_id      :integer
#  team_id     :integer
#  name        :string(255)
#  sweater     :integer
#  player_type :string(255)
#

class Player < ActiveRecord::Base

	# Callbacks

	# Valiadations
	validates :nhl_id, presence: true, uniqueness: true
	validates :team_id, presence: true
	validates :name, presence: true

	# Relationships
	belongs_to :team
	has_many :skater_stats, class_name: 'SkaterStat', foreign_key: 'player_id'
	has_many :goalie_stats, class_name: 'GoalieStat', foreign_key: 'player_id'
	has_many :games, through: :stats, source: :game

	# Functions
	def games_played
		games.count
	end

	# Class Functions
	def self.search(query)
		Player.find_by(name: query)
	end
end
