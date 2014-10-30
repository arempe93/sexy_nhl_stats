# Require
require 'rubygems'
require 'json'
require 'open-uri'

require 'sinatra/activerecord'
require_relative '../../models/team'
require_relative '../../models/player'

# Drop current goalies
Player.delete_all("player_type = 'G'")

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

		# Skip if no goalie information present
		next if play['type'] != 'Shot'

		# Skip if this goalie has already been stored
		next if Player.find_by(nhl_id: play['pid2'])

		# Get the team the goalie was on
		goalie_nhl_team_id = play['teamid'] == home_team_id ? away_team_id : home_team_id
		goalie_team_id = goalie_nhl_team_id == home_team_id ? home_team.id : away_team.id

		# Get the goalie nhl id
		goalie_nhl_id = play['pid2']

		# Create goalie record
		goalie = Player.new(nhl_id: goalie_nhl_id, team_id: goalie_team_id, name: play['p2name'], player_type: 'G')

		# Open gcbx file
		gcbx_file = open("http://live.nhl.com/GameData/20142015/#{id}/gc/gcbx.jsonp")
		gcbx = JSON.parse(gcbx_file.read[10..-2])

		# Handle multiple goaltender situation for this game
		goalie_team_name = goalie_team_id == home_team.id ? 'home' : 'away'

		if gcbx['rosters'][goalie_team_name]['goalies'].length > 1

			saves_made = 0

			# Loop through plays again to find last shot against
			stats['plays']['play'].each do |shot|

				# Skip this play if not a shot by the other team or was made in the shootout
				next if shot['type'] != 'Shot' or shot['teamid'] == goalie_nhl_team_id or shot['period'] == 5

				# Skip if this shot was made against another goalie
				next if shot['pid2'] != goalie_nhl_id

				# Increment this goalie's saves
				saves_made += 1
			end

			puts "\n\n\n\n\n\nGAME ID: #{id}\nGOALIE ID: #{goalie.nhl_id}\nGOALIE NAME: #{goalie.name}\nSAVES COUNTED: #{saves_made}\n\n\n\n\n\n"

			# Loop through goalies to find the correct one
			gcbx['rosters'][goalie_team_name]['goalies'].each do |goalie_record|

				# Find matching goalie to find jersey number
				if goalie_record['sv'] == saves_made

					goalie.sweater = goalie_record['num']
					break
				end
			end
		else
			goalie.sweater = gcbx['rosters'][goalie_team_name]['goalies'].first['num']
		end

		# Save goalie record
		goalie.save
	end
end