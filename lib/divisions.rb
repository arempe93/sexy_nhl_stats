# Require
require 'sinatra/activerecord'
require_relative '../models/team'

# Create list of teams for all divisions
metro = [
	Team.find_by abbv:
]