# == Schema Information
#
# Table name: team_stats
#
#  id        :integer          not null, primary key
#  team_id   :integer
#  game_id   :integer
#  shots     :integer
#  blocks    :integer
#  pim       :integer
#  hits      :integer
#  fow       :integer
#  takeaways :integer
#  giveaways :integer
#  penalties :string(255)
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

		numbers.first.to_i / numbers.last.to_i
	end

	def net_posession
		takeaways - giveaways
	end
end