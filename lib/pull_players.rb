# Require
require 'rubygems'
require 'json'
require 'open-uri'

require 'sinatra/activerecord'
require_relative '../models/team'
require_relative '../models/player'

# Drop current games
Player.delete_all

# Season file
season_file = open("http://live.nhl.com/GameData/SeasonSchedule-20142015.json")
season = JSON.parse season_file.read

# Loop through all games
season.each do |game|

	# Get game id
	id = game['id']

	# Limit loop
	break if id == 2014020137

	puts "Opening game: #{id}"

	# Open playbyplay file
	stats_file = open("http://live.nhl.com/GameData/20142015/#{id}/PlayByPlay.json")
	stats = JSON.parse(stats_file.read)['data']['game']

	# Get team ids
	home_team_id = stats['hometeamid']
	away_team_id = stats['awayteamid']

	# Get both teams or if they exist
	home_team = Team.find_by(nhl_id: stats['hometeamid'])
	away_team = Team.find_by(nhl_id: stats['awayteamid'])

	# Loop through all game plays
	stats['plays']['play'].each do |play|

		# Get goalie information if possible
		if play['type'] == 'Shot'

			# Skip this goalie if already stored
			unless Player.find_by(nhl_id: play['pid2'])

				# Get the team the goalie was on
				goalie_team_id = play['teamid'] == home_team_id ? away_team.id : home_team.id

				# Create goalie record
				goalie = Player.create(nhl_id: play['pid2'], team_id: goalie_team_id, name: play['p2name'], player_type: 'G')
			end
		end

		# Get the player id
		player_id = play['pid']

		# Skip this play if the player has been retrieved or doesn't exist
		next if not player_id or Player.find_by(nhl_id: player_id)

		# Also skip penalties with a 3rd man (Goalie penalty)
		next if play['type'] == 'Penalty' and play['pid3']

		# Get the team the player was on
		player_team_id = play['teamid'] == home_team_id ? home_team.id : away_team.id

		# Get player information
		player = Player.create(nhl_id: player_id, team_id: player_team_id, name: play['playername'], sweater: play['sweater'], player_type: 'S')
	end
end