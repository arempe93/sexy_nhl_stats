# Require
require 'rubygems'
require 'json'
require 'open-uri'

require 'sinatra/activerecord'
require_relative '../../models/team'
require_relative '../../models/player'

# Drop current skaters
Player.delete_all("player_type = 'S'")

# Season file
season_file = open("http://live.nhl.com/GameData/SeasonSchedule-20142015.json")
season = JSON.parse season_file.read

# Loop through all games
season.each do |game|

	# Get game id
	id = game['id']

	# Limit loop
	next unless DateTime.now > DateTime.parse(game['est'])

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