#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

$PSQL 'truncate table teams cascade'
$PSQL 'truncate table games cascade'


function GET_TEAM_ID {
  TEAM_NAME=$@
  TEAM_ID=$($PSQL "select team_id from teams where name='$TEAM_NAME'")
  if [[ -z $TEAM_ID ]]
  then
    INSERT_TEAM_RESULT=$($PSQL "insert into teams(name) values('$TEAM_NAME')")
    TEAM_ID=$($PSQL "select team_id from teams where name='$TEAM_NAME'")
  fi
  echo $TEAM_ID
}

# Do not change code above this line. Use the PSQL variable above to query your database.
# read file and ignore first line (headers)
sed 1d games.csv|while IFS=',' read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # insert teams
  WINNER_TEAM_ID=$(GET_TEAM_ID $WINNER)
  OPPONENT_TEAM_ID=$(GET_TEAM_ID $OPPONENT)
  # insert game
  $PSQL "insert into games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) values($YEAR,'$ROUND',$WINNER_TEAM_ID,$OPPONENT_TEAM_ID,$WINNER_GOALS,$OPPONENT_GOALS)"
done
