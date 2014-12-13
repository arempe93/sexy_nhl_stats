# Require
require 'sinatra/activerecord'
require_relative '../models/team'

# Create list of teams for all divisions
atlantic = [
	Team.find_by(abbv: 'TBL'),
	Team.find_by(abbv: 'DET'),
	Team.find_by(abbv: 'MTL'),
	Team.find_by(abbv: 'TOR'),
	Team.find_by(abbv: 'FLA'),
	Team.find_by(abbv: 'BOS'),
	Team.find_by(abbv: 'OTT'),
	Team.find_by(abbv: 'BUF')
]

metro = [
	Team.find_by(abbv: 'PIT'),
	Team.find_by(abbv: 'NYI'),
	Team.find_by(abbv: 'WSH'),
	Team.find_by(abbv: 'NYR'),
	Team.find_by(abbv: 'NJD'),
	Team.find_by(abbv: 'PHI'),
	Team.find_by(abbv: 'CBJ'),
	Team.find_by(abbv: 'CAR')
]

central = [
	Team.find_by(abbv: 'CHI'),
	Team.find_by(abbv: 'NSH'),
	Team.find_by(abbv: 'WPG'),
	Team.find_by(abbv: 'STL'),
	Team.find_by(abbv: 'MIN'),
	Team.find_by(abbv: 'COL'),
	Team.find_by(abbv: 'DAL')
]

pacific = [
	Team.find_by(abbv: 'ANA'),
	Team.find_by(abbv: 'VAN'),
	Team.find_by(abbv: 'CGY'),
	Team.find_by(abbv: 'SJS'),
	Team.find_by(abbv: 'LAK'),
	Team.find_by(abbv: 'ARI'),
	Team.find_by(abbv: 'EDM')
]

# Fill in conference and division information

metro.each do |t|
	t.conference = 'East'
	t.division = 'Metropolitan'
	t.save
end

atlantic.each do |t|
	t.conference = 'East'
	t.division = 'Atlantic'
	t.save
end

central.each do |t|
	t.conference = 'West'
	t.division = 'Central'
	t.save
end

pacific.each do |t|
	t.conference = 'West'
	t.division = 'Pacific'
	t.save
end