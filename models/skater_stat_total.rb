# == Schema Information
#
# Table name: skater_stat_totals
#
#  id         :integer          not null, primary key
#  player_id  :integer
#  goals      :integer          default("0")
#  assists    :integer          default("0")
#  shots      :integer          default("0")
#  pim        :integer          default("0")
#  pm         :integer          default("0")
#  created_at :datetime
#  updated_at :datetime
#

class SkaterStatTotal < ActiveRecord::Base

	# Relationships are hard
	belongs_to :player

	# Helper methods
	def points
		goals + assists
	end

	def shooting_percentage
		goals.to_f / shots.to_f
	end
end
