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

	# Open stats file
	gcbx_file = open("http://live.nhl.com/GameData/20142015/#{game.nhl_id}/gc/gcbx.jsonp")
	gcbx = JSON.parse(gcbx_file.read[10..-2])

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