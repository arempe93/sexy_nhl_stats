require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/partial'
require 'require_all'

require_all 'models'

get '/'  do
	erb '<h1>Hello World!</h1>'
end