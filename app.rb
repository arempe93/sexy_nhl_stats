require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/partial'

require './models/team'

get '/'  do
	erb '<h1>Hello World!</h1>'
end