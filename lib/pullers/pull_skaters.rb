# Require
require 'rubygems'
require 'json'
require 'open-uri'

require 'sinatra/activerecord'
require_relative '../../models/team'
require_relative '../../models/player'

# Drop current skaters
Player.delete_all("player_type = 'S'")

# Loop through all games
Game.all_played_games.each do |game|

	puts "Opening game: #{game.nhl_id}"

	# Open playbyplay file
	stats_file = open("http://live.nhl.com/GameData/20142015/#{game.nhl_id}/PlayByPlay.json")
	stats = JSON.parse(stats_file.read)['data']['game']

	# Get both teams
	home_team = game.home_team
	away_team = game.away_team

	# Loop through all game plays
	stats['plays']['play'].each do |play|

		# Get the player id
		player_id = play['pid']

		# Skip this play if the player has been retrieved or doesn't exist
		next if not player_id or Player.find_by(nhl_id: player_id)

		# Also skip penalties with a 3rd man (Goalie penalty)
		next if play['type'] == 'Penalty' and play['pid3']

		# Get the team the player was on
		player_team_id = play['teamid'] == home_team.nhl_id ? home_team.id : away_team.id

		# Get player information
		player = Player.create(nhl_id: player_id, team_id: player_team_id, name: play['playername'], sweater: play['sweater'], player_type: 'S')
	end
end