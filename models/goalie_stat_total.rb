# == Schema Information
#
# Table name: goalie_stat_totals
#
#  id            :integer          not null, primary key
#  player_id     :integer
#  shots_faced   :integer          default("0")
#  saves         :integer          default("0")
#  goals_against :integer          default("0")
#  shutouts      :integer          default("0")
#  wins          :integer          default("0")
#  toi           :time             default("05:00:00")
#  created_at    :datetime
#  updated_at    :datetime
#

class GoalieStatTotal < ActiveRecord::Base

	# Relationships
	belongs_to :player

	# Functions
	
end
