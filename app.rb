require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/partial'
require 'require_all'

require_relative 'config/environments'

require_all 'models'

get '/'  do
	erb :'pages/home'
end

# Teams

get '/teams/?' do
	@teams = Team.all.order(:city)
	erb :'pages/teams'
end

get '/teams/:abbv/?' do
	@team = Team.find_by abbv: params[:abbv]
	erb :'teams/show'
end

# Players

get '/players/?' do
	@players = Player.all.order(:name)
	erb :'pages/players'
end

get '/players/:nhl_id/?' do
	@player = Player.find_by nhl_id: params[:nhl_id]
	erb :'players/show'
end