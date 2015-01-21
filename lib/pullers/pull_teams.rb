# Pulls all NHL teams and stores them in the database
### Drops table
### Iterates through just enough games to make sure every team plays at least once
### Collects data from each team to store in database
###### Follows team.rb model

# Require
require 'rubygems'
require 'json'
require 'open-uri'

require 'sinatra/activerecord'
require_relative '../../models/team'

# Drop current games
Team.delete_all

# Season file
season_file = open("http://live.nhl.com/GameData/SeasonSchedule-20142015.json")
season = JSON.parse season_file.read

# Minimum stopping point to get all teams
stopping_point = 2014020018

# Loop through all games
season.each do |game|

	# Get game id
	id = game['id']

	# Limit loop
	break if id == stopping_point

	puts "Opening game: #{id}"

	# Get team abbreviations
	home_team_abbv = game['h']
	away_team_abbv = game['a']

	# Open playbyplay file
	stats_file = open("http://live.nhl.com/GameData/20142015/#{id}/PlayByPlay.json")
	stats = JSON.parse(stats_file.read)['data']['game']

	# Get team ids
	home_team_id = stats['hometeamid']
	away_team_id = stats['awayteamid']

	# Get both teams or if they exist
	home_team = Team.find_by(nhl_id: stats['hometeamid'])
	away_team = Team.find_by(nhl_id: stats['awayteamid'])

	# Skip team scraping if both teams have already been scraped
	unless home_team and away_team

		# Get and store team information
		home_name = stats['hometeamname'].split ' '
		away_name = stats['awayteamname'].split ' '

		# Store team if it doesn't already exist
		home_team = Team.create(nhl_id: home_team_id, city: home_name.first(home_name.count - 1).join(' '), name: home_name.last, abbv: home_team_abbv) unless home_team
		away_team = Team.create(nhl_id: away_team_id, city: away_name.first(away_name.count - 1).join(' '), name: away_name.last, abbv: away_team_abbv) unless away_team
	
		puts "Recording home team: #{home_team.name}"
		puts "Recording away team: #{away_team.name}"
	end
end