# == Schema Information
#
# Table name: skater_stat_totals
#
#  id         :integer          not null, primary key
#  player_id  :integer
#  goals      :integer
#  assists    :integer
#  shots      :integer
#  pim        :integer
#  pm         :integer
#  created_at :datetime
#  updated_at :datetime
#

class SkaterStatTotals < ActiveRecord::Base


	# Helper methods
	def points
		goals + assists
	end

	def shooting_percentage
		goals.to_f / shots.to_f
	end
end
