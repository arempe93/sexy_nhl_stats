require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/partial'
require 'require_all'

require_relative 'config/environments'

require_all 'models'

helpers do
	def humanize_number(number)
		number.to_s.reverse.gsub(/...(?=.)/,'\&,').reverse
	end
end

get '/'  do
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