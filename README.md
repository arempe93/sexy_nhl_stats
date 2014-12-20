NHL Stats Tracker
=================

Uses the NHL GameCenter internal JSON API to extract and display stats in a sexy manner.

Accumulative Stats
------------------

The name of the game is accumulative statistics. Rather than provide a lump sum for a player's stats, we want to show rates of change on many of the stats a player can get to show deeper insight than most stat pages show. 

We gather all of our data from individual games throughout the season. Once a day we pull in the stats from the previous day and add them to the database. Each skater, goalie, and team will then get a new 'stat' added to their database table. These 'stat's are a hard thing to name. They hold all the stats for that skater, goalie, or team for that specific game, not totals for the season. With all these stats kept separate, this allows us to show these rates.

All this is handled by the pullers we wrote to help us accumulate the data.

Pullers
-------

Pullers are how we get all our stats. Now there are a lot of stats and it is a lot to process. In a runtime environment we would run our updater once a day to gather new stats from all the pullers. In a development environment, wiping the database to pull everything is time consuming and necessary. Here is a guide that shows you what Ruby files to run.

```
rake db:reset
```
will clear your entire database and run ```/lib/pull_all.rb``` which in turn will run ```/lib/pullers/pull_teams.rb```, ```/lib/pullers/pull_games.rb```, and ```/lib/pullers/pull_database.rb``` in that order. The last thing run will be ```/lib/divisions.rb``` which just tells the database to which division each team belongs.


+ pull_teams.rb: Populate Teams table with every NHL team and relevant information.
+ pull_games.rb: Populate Games table with every NHL game *that has been played so far*. Also responsible for updating team records with proper win/loss information.
+ pull_database.rb: Where all the magic happens. Starts by finding all skaters, and goalies to play in a particular game, then logs their stats for that specific game. Because everything happens on a per game basis, all stats are recorded based on the game, not a sum or lump total for the season. 