# Require
require 'rubygems'
require 'json'
require 'open-uri'

require 'sinatra/activerecord'
require_relative '../../models/team'
require_relative '../../models/player'
require_relative '../../models/game'
require_relative '../../models/skater_stat'

# Drop current games
SkaterStat.delete_all

# Season file
season_file = open("http://live.nhl.com/GameData/SeasonSchedule-20142015.json")
season = JSON.parse season_file.read

# Loop through all games
season.each do |game_record|

	# Get game id
	id = game_record['id']

	# Limit loop
	next unless DateTime.now > DateTime.parse(game_record['est'])

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
				SkaterStat.create(player_id: player.id, game_id: game.id, team_id: player.team.id, goals: record['g'], assists: record['a'], shots: record['sog'], pim: record['pim'], pm: record['pm'], toi: "00:" + record['toi'])
			end
		end
	end
end