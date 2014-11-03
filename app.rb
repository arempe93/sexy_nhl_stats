require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/partial'
require 'require_all'

require_relative 'config/environments'

require_all 'models'

get '/'  do
	erb :'pages/home'
end

get '/teams/?' do
	@teams = Team.all.order(:city)
	erb :'pages/teams'
end