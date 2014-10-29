class Player < ActiveRecord::Base

	# Callbacks

	# Valiadations
	validates :nhl_id, presence: true, uniqueness: true
	validates :team_id, presence: true
	validates :name, presence: true

	# Relationships
	belongs_to :team

	# Functions
end
