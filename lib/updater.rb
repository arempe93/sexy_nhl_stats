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
	game_stats_file = open("http://live.nhl.com/GameData/20142015/#{game.nhl_id}/gc/gcsb.jsonp")
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
