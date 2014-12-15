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

Game.all_played_games.each do |game|

	puts "Analyzing game: #{game.nhl_id}"

	
end