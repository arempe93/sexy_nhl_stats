require 'sinatra/activerecord'

# Disable database output
old_logger = ActiveRecord::Base.logger
ActiveRecord::Base.logger = nil

# Redirect output to log file
$stdout.reopen(File.expand_path('../../logs/seed.txt', __FILE__), 'w')

# Run all pullers
require_relative '../lib/pull_all'

# Manually fix some team names
mapleleafs = Team.find_by nhl_id: 10
mapleleafs.name = 'Maple Leafs'		# was Leafs
mapleleafs.city = 'Toronto' 		# was Toronto Maple
mapleleafs.save

redwings = Team.find_by nhl_id: 17
redwings.name = 'Red Wings'			# was Wings
redwings.city = 'Detroit'			# was Detroit Red
redwings.save

bluejackets = Team.find_by nhl_id: 29
bluejackets.name = 'Blue Jackets'	# was Jackets
bluejackets.city = 'Columbus'		# was Columbus Blue
bluejackets.save

# Re-enable database output
ActiveRecord::Base.logger = old_logger