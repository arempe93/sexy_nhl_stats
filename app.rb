require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/partial'
require 'require_all'

require_relative 'config/environments'

require_all 'models'

get '/'  do
	@teams = Team.count
	@players = Player.where(player_type: 'S').count
	@skater_stats = SkaterStat.count
	@goalies = Player.where(player_type: 'G').count
	@games = Game.count
	erb :'pages/home'
end

get '/teams/?' do
	@teams = Team.all.order(:city)
	erb :'pages/teams'
end

get '/players/?' do
	@players = Player.all.order(:name)
	erb :'pages/players'
end