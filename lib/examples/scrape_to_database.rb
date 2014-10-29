# Pulls NHL team and player information and stores it in a database

# Require
require 'rubygems'
require 'json'
require 'open-uri'

# Include database code
require_relative 'database_helper'
include DatabaseHelper

# Drop current tables
Team.delete_all
Player.delete_all
Game.delete_all
SkaterStats.delete_all

# Stop loop on this game id
stopping_point = 2014020121

# Season file
season_file = open("http://live.nhl.com/GameData/SeasonSchedule-20142015.json")
season = JSON.parse season_file.read

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
	end

	# Create game record
	Game.create(nhl_id: id, game_time: game['est'], home_team_id: home_team.id, away_team_id: away_team.id)

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

# Loop through season again for stats
season.each do |game_record|

	# Get game id
	id = game_record['id']

	# Limit loop
	break if id == stopping_point

	# Get game record
	game = Game.find_by(nhl_id: id)

	# Get team ids
	home_id = Team.find_by(abbv: game_record['h']).id
	away_id = Team.find_by(abbv: game_record['a']).id

	# Open stats file
	gcbx_file = open("http://live.nhl.com/GameData/20142015/#{id}/gc/gcbx.jsonp")
	gcbx = JSON.parse(gcbx_file.read[10..-2])

	# Retrieves both home and away stats
	gcbx['rosters'].each do |roster_team|

		# Extrapolate team id
		roster_team_id = roster_team.include?("home") ? home_id : away_id
		
		roster_team[1]['skaters'].each do |record|
			player = Player.find_by(team_id: roster_team_id, sweater: record['num'])

			# Create stats record if the player exists
			if player
				SkaterStats.create(player_id: player.id, game_id: game.id, goals: record['g'], assists: record['a'], shots: record['sog'], pim: record['pim'], pm: record['pm'], toi: "00:" + record['toi'])
			end
		end

		roster_team[1]['goalies'].each do |record|
			goalie = Player.find_by(team_id: roster_team_id, sweater: record['num'], player_type: 'G')

			# Create stats recrod if the goalie exists
			if goalie
				GoalieStats.create(player_id: goalie.id, game_id: game.id, shots_against: record['sa'], saves: record['sv'], goals_against: record['ga'], toi: "00:" + record['toi'])
			end
		end
	end

	# Calculate score of the game
	home_score = 0
	away_score = 0	

	SkaterStats.all.where(game_id: game.id).each do |stat|

		if Player.find(stat.player_id).team_id == home_id
			home_score += stat.goals
		else
			away_score += stat.goals
		end
	end

	puts game.id
	puts "#{home_score} - #{away_score}"
	puts gcbx['goalSummary'].include?('per4')
	puts "\n"

	# Update game record
	#game.update_attributes(home_score: home_score, away_score: away_score, decision: gcbx['goalSummary'].include?('per4') ? 'O' : 'F')
end