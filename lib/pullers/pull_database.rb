# Require
require 'rubygems'
require 'json'
require 'open-uri'

require 'sinatra/activerecord'
require_relative '../../models/team'
require_relative '../../models/player'
require_relative '../../models/game'
require_relative '../../models/skater_stat'
require_relative '../../models/goalie_stat'
require_relative '../../models/team_stat'

# Loop through all played games
Game.all_played_games.each do |game|

	puts "Analyzing game: #{game.nhl_id}"

	# Get teams
	home_team = Team.find game.home_team_id
	away_team = Team.find game.away_team_id

	# Open playbyplay file
	stats_file = open("http://live.nhl.com/GameData/20142015/#{game.nhl_id}/PlayByPlay.json")
	stats = JSON.parse(stats_file.read)['data']['game']

	# Open stats file
	gcbx_file = open("http://live.nhl.com/GameData/20142015/#{game.nhl_id}/gc/gcbx.jsonp")
	gcbx = JSON.parse(gcbx_file.read[10..-2])

	### GET SKATERS ###

	stats['plays']['play'].each do |play|

		# Get the player id
		player_id = play['pid']

		# Skip this play if the player has been retrieved or doesn't exist
		next if not player_id or Player.find_by(nhl_id: player_id)

		# Also skip penalties with a 3rd man (Goalie penalty)
		next if play['type'] == 'Penalty' and play['pid3']

		# Get the team the player was on
		player_team_id = ((play['teamid'] == home_team.nhl_id) ? home_team.id : away_team.id)

		# Get player information
		player = Player.create(nhl_id: player_id, team_id: player_team_id, name: play['playername'], sweater: play['sweater'], player_type: 'S')
	end

	### GET GOALIES ###

	stats['plays']['play'].each do |play|

		# Skip if no goalie information present
		next if play['type'] != 'Shot'

		# Skip if this goalie has already been stored
		next if Player.find_by(nhl_id: play['pid2'])

		# Get the team the goalie was on
		goalie_nhl_team_id = ((play['teamid'] == home_team_id) ? away_team_id : home_team_id)
		goalie_team_id = ((goalie_nhl_team_id == home_team_id) ? home_team.id : away_team.id)

		# Get the goalie nhl id
		goalie_nhl_id = play['pid2']

		# Create goalie record
		goalie = Player.new(nhl_id: goalie_nhl_id, team_id: goalie_team_id, name: play['p2name'], player_type: 'G')

		# Open gcbx file
		gcbx_file = open("http://live.nhl.com/GameData/20142015/#{id}/gc/gcbx.jsonp")
		gcbx = JSON.parse(gcbx_file.read[10..-2])

		# Handle multiple goaltender situation for this game
		goalie_team_name = ((goalie_team_id == home_team.id) ? 'home' : 'away')

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

	### GET STATS ###

	gcbx['rosters'].each do |roster_team|

		# Extrapolate team id
		roster_team_id = roster_team.include?("home") ? home_team.id : away_team.id
		
		# Retrieve skater stats
		roster_team[1]['skaters'].each do |record|
			player = Player.find_by(team_id: roster_team_id, sweater: record['num'])

			# Create stats record if the player exists
			if player
				SkaterStat.create(player_id: player.id, game_id: game.id, team_id: player.team.id, goals: record['g'], assists: record['a'], shots: record['sog'], pim: record['pim'], pm: record['pm'], toi: "00:" + record['toi'])
			end
		end

		# Retrieve goalie stats
		roster_team[1]['goalies'].each do |record|
			goalie = Player.find_by(team_id: roster_team_id, sweater: record['num'])

			# Create stats record if the goalie exists
			if goalie
				GoalieStat.create(player_id: goalie.id, game_id: game.id, team_id: goalie.team.id, shots_faced: record['sa'], saves: record['sv'], goals_against: record['ga'], toi: "00:" + record['toi'])
			end
		end
	end

	### LOGGING ###

	puts "Skaters: #{Player.where(player_type: 'S').count}"
	puts "Stats: #{SkaterStat.count}\n\n"
	puts "Goalies: #{Player.where(player_type: 'G').count}"
	puts "Stats: #{GoalieStat.count}"
end