# Updates games played since last update

# Require
require 'rubygems'
require 'json'
require 'open-uri'

require 'sinatra/activerecord'
require_relative '../models/team'
require_relative '../models/player'
require_relative '../models/game'
require_relative '../models/skater_stat'
require_relative '../models/goalie_stat'

# Redirect output to log file
$stdout.reopen(File.expand_path('../../logs/update.txt', __FILE__), 'w')

# Log time ran
puts "======== Updated at #{DateTime.now} ========"

# Find all games played but not stored
unstored_games = Game.where("home_team_score is null AND date_trunc('day', game_time) < '#{Date.today}'").order(:nhl_id)

# Loop through all unstored games
unstored_games.each do |game|

	# Log game
	puts "Opening game: #{game.nhl_id}"

	# Get teams
	home_team = Team.find game.home_team_id
	away_team = Team.find game.away_team_id

	# Open playbyplay file
	stats_file = open("http://live.nhl.com/GameData/20142015/#{game.nhl_id}/PlayByPlay.json")
	stats = JSON.parse(stats_file.read)['data']['game']

	# Open stats file
	gcbx_file = open("http://live.nhl.com/GameData/20142015/#{game.nhl_id}/gc/gcbx.jsonp")
	gcbx = JSON.parse(gcbx_file.read[10..-2])

	# Open scoreboard file
	game_stats_file = open("http://live.nhl.com/GameData/20142015/#{id}/gc/gcsb.jsonp")
	game_stats = JSON.parse(game_stats_file.read[10..-2])

	### GAME UPDATES ###

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
	game.save
end
	### PLAYER UPDATES ###

	# Update players
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

	# Update goalies
	stats['plays']['play'].each do |play|

		# Skip if no goalie information present
		next if play['type'] != 'Shot'

		# Skip if this goalie has already been stored
		next if Player.find_by(nhl_id: play['pid2'])

		# Get the team the goalie was on
		goalie_nhl_team_id = play['teamid'] == home_team.nhl_id ? away_team.nhl_id : home_team.nhl_id
		goalie_team_id = goalie_nhl_team_id == home_team.nhl_id ? home_team.id : away_team.id

		# Get the goalie nhl id
		goalie_nhl_id = play['pid2']

		# Create goalie record
		goalie = Player.new(nhl_id: goalie_nhl_id, team_id: goalie_team_id, name: play['p2name'], player_type: 'G')

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

	### STATS ###

	# Loop through home and away rosters
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

		# Log skater stats
		puts "Created #{SkaterStat.where(game_id: game.id).count} skater stats"

		# Retrieve goalie stats
		roster_team[1]['goalies'].each do |record|
			goalie = Player.find_by(team_id: roster_team_id, sweater: record['num'])

			# Create stats record if the goalie exists
			if goalie
				GoalieStat.create(player_id: goalie.id, game_id: game.id, team_id: goalie.team.id, shots_faced: record['sa'], saves: record['sv'], goals_against: record['ga'], toi: "00:" + record['toi'])
			end
		end

		# Log goalie stats
		puts "Created #{GoalieStat.where(game_id: game.id).count} skater stats\n\n"
	end
end