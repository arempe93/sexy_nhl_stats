# Pulls all NHL games and stores them in the database
### Drops table to start
### Reads all games from Schedule JSON file
### Create an entry for the game in the database
###### If the game has been played already:
###### Store information about the game, winner, score etc.
### Save all information in database according to game.rb model

# Require
require 'rubygems'
require 'json'
require 'open-uri'

require 'sinatra/activerecord'
require_relative '../../models/game'
require_relative '../../models/team'

# Drop current games
Game.delete_all

# Season file
season_file = open("http://live.nhl.com/GameData/SeasonSchedule-20142015.json")
season = JSON.parse season_file.read

# Loop through all games
season.each do |game|

	# Get game id
	id = game['id']

	puts "Opening game: #{id}"

	# Get team abbreviations
	home_team_abbv = game['h']
	away_team_abbv = game['a']

	# Get both teams
	home_team = Team.find_by(abbv: home_team_abbv)
	away_team = Team.find_by(abbv: away_team_abbv)

	# Get the game date
	game_date = DateTime.parse game['est']

	# Create initial Game record
	game = Game.new(nhl_id: id, game_time: game_date, home_team_id: home_team.id, away_team_id: away_team.id)
	
	# If this game has already been played
	if DateTime.now > game_date
	
		# Open scoreboard file
		game_stats_file = open("http://live.nhl.com/GameData/20142015/#{id}/gc/gcsb.jsonp")
		game_stats = JSON.parse(game_stats_file.read[10..-2])

		# Get home and away scores
		away_score = game_stats['a']['tot']['g']
		home_score = game_stats['h']['tot']['g']

		# Get game decision
		periods_played = game_stats['p']
		game_decision = periods_played == 3 ? 'F' : (periods_played == 4 ? 'OT' : 'SO')

		# Update Game record
		game.home_team_score = home_score
		game.away_team_score = away_score
		game.decision = game_decision
		
		# Update team records
		winner = (home_score > away_score ? home_team : away_team)
		loser = (home_score > away_score ? away_team : home_team)

		# Increment proper values
		winner.wins += 1
		if game_decision == 'F'
			loser.losses += 1
		else
			loser.ot += 1
		end

		winner.row += 1 if game_decision != 'SO'

		# Save changes
		winner.save
		loser.save
	end
	
	# Save changes
	game.save
end