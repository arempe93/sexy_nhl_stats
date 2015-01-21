# Set up database puller output
old_logger = ActiveRecord::Base.logger
ActiveRecord::Base.logger = nil

# Require all pullers and sort output
$stdout.reopen(File.expand_path('../../logs/pull_teams_log.txt', __FILE__), 'w')
require_relative 'pullers/pull_teams'

$stdout.reopen(File.expand_path('../../logs/pull_games_log.txt', __FILE__), 'w')
require_relative 'pullers/pull_games'

$stdout.reopen(File.expand_path('../../logs/pull_db_log.txt', __FILE__), 'w')
require_relative 'pullers/pull_database'

$stdout.reopen(File.expand_path('../../logs/divisions_log.txt', __FILE__), 'w')
require_relative 'divisions'

ActiveRecord::Base.logger = old_logger