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

This section gets very techy very fast. It is meant mainly for contributors than curious onlookers.

Pullers are how we get all our stats. Now there are a lot of stats and it is a lot to process. In a runtime environment we would run our updater once a day to gather new stats from all the pullers. In a development environment, wiping the database to pull everything is time consuming and necessary. Here is a guide that shows you what Ruby files to run.

```
rake db:reset
```
will clear your entire database and run ```/lib/pull_all.rb``` which in turn will run ```/lib/pullers/pull_teams.rb```, ```/lib/pullers/pull_games.rb```, and ```/lib/pullers/pull_database.rb``` in that order. The last thing run will be ```/lib/divisions.rb``` which just tells the database to which division each team belongs.


+ **pull_teams.rb**: Populate Teams table with every NHL team and relevant information.
+ **pull_games.rb**: Populate Games table with every NHL game *that has been played so far*. Also responsible for updating team records with proper win/loss information.
+ **pull_database.rb**: Where all the magic happens. Starts by finding all skaters, and goalies to play in a particular game, then logs their stats for that specific game. Because everything happens on a per game basis, all stats are recorded based on the game, not a sum or lump total for the season. 

```
ruby /lib/updater.rb
```
is what is cron'ed to update the database with new entries every day. It looks up all information, teams, games, players, and updates the database accordingly.

Stat Display
------------

We are starting out just displaying the stats in a stale and common manner. The reasoning behind this is to make sure everything works before we kick it up a notch. Navigating to the team index page will show the current standings for each team. The exciting part of this is that it is entirely automated content, generated on the spot from information from our database. This allows us to quickly expand upon later to bring you features such as a team's point collection over time revealing very clearly what teams are the hottest, i.e. accumuluating the most points over a recent stretch of time. 

Each players page for now will just show a table of all their games and statistics, again all dynamically generated from information from our database. Again this is for testing purposes to ensure accuracy in our data collection methods. Once we know everything works, we will build this up to be able to show how these stats have changed over time for a particular player, perhaps with player by player comparison to show who has the hotter hands over the past month.

Creators
--------

This project is made entirely by [Chris Celi](www.github.com/celic) and [Andrew Rempe](www.github.com/arempe93). We would like to thank the NHL for not hiding their JSON files though. We found them publically available and we assume they are free to use as such. :)

Thanks!