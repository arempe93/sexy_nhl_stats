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
	if @player.player_type == 'S'
		erb :'players/skater_show'
	else
		erb :'players/goalie_show'
	end
end

get '/leaders' do
	@players = Player.where(player_type: 'S')
	@goalies = Player.where(player_type: 'G')

	@goals = @players.sort_by { |player| player.goals, -player.games_played }[0..10]
	@assists = @players.sort_by { |player| player.assists, -player.games_played }[0..10]
	@points = @players.sort_by { |player| player.goals + player.assists, -player.games_played }[0..10]
	@plus_minus = @players.sort_by { |player| player.pm, player.games_played }[0..10]
	@pims = @players.sort_by { |player| player.pims, -player.games_played }[0..10]

	erb :'pages/leaders'
end

get '/legal' do
	erb :'pages/legal'
end

get '/about' do
	erb :'pages/about'
end

get '/contact' do
	erb :'pages/contact'
end