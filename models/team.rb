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

	# Functions
end
