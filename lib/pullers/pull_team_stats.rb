# Require
require 'rubygems'
require 'json'
require 'open-uri'

require 'sinatra/activerecord'
require_relative '../../models/team'
require_relative '../../models/game'
require_relative '../../models/team_stat'

# Drop current team stats
TeamStat.delete_all

# Clear team records
Team.all.each do |team|
	team.wins = 0
	team.losses = 0
	team.ot = 0
	team.row = 0
end

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

	# Record winner and loser
	away_score = game_stats['a']['tot']['g']
	home_score = game_stats['h']['tot']['g']
	periods_played = game_stats['p']	
	game_decision = periods_played == 3 ? 'F' : (periods_played == 4 ? 'OT' : 'SO')	
	home_team = Team.find_by(id: home_id)
	away_team = Team.find_by(id: away_id)

	winner = (home_score > away_score ? home_team : away_team)
	loser = (home_score > away_score ? away_team : home_team)

	winner.wins += 1
	if game_decision == 'F'
		loser.losses += 1
	else
		loser.ot += 1
	end

	winner.save
	loser.save
	
	# Retrieve home team stats
	home_stats = gcbx['teamStats']['home']
	home_shots = gcbx['shotSummary'].last['shots'][0]['hShotTot']

	TeamStat.create(team_id: home_id, game_id: game.id, shots: home_shots, blocks: home_stats['hBlock'], pim: home_stats['hPIM'], hits: home_stats['hHits'], fow: home_stats['hFOW'], takeaways: home_stats['hTake'], giveaways: home_stats['hGive'], penalties: home_stats['hPP'])

	# Retrieve away team stats
	away_stats = gcbx['teamStats']['away']
	away_shots = gcbx['shotSummary'].last['shots'][0]['aShotTot']

	TeamStat.create(team_id: away_id, game_id: game.id, shots: away_shots, blocks: away_stats['aBlock'], pim: away_stats['aPIM'], hits: away_stats['aHits'], fow: away_stats['aFOW'], takeaways: away_stats['aTake'], giveaways: away_stats['aGive'], penalties: away_stats['aPP'])
end