#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo -e "\nTables Truncated\n"
$PSQL "TRUNCATE games, teams"

echo -e "\nteam_id sequence is reseted to 1"
$PSQL "ALTER SEQUENCE teams_team_id_seq RESTART WITH 1"
echo -e "\ngame_id sequence is reseted to 1"
$PSQL "ALTER SEQUENCE games_game_id_seq RESTART WITH 1"

cat games.csv | while IFS="," read -r _ _ WINNER OPPONENT _ _ _
do 
  if [[ $WINNER == "winner" ]]
  then
    continue
  fi
  IS_WINNER_ADDED="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
  IS_OPPONENT_ADDED="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"
  if [[ -z $IS_WINNER_ADDED ]]
  then
    echo -e "\n$WINNER added"
    $PSQL "INSERT INTO teams(name) VALUES ('$WINNER')"
  fi
  if [[ -z $IS_OPPONENT_ADDED ]]
  then 
    echo -e "\n$OPPONENT added"
    $PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')"
  fi
done

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR == "year" ]]
  then
    continue
  fi
  WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
  OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"
  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES('$YEAR', '$ROUND', '$WINNER_ID', '$OPPONENT_ID', '$WINNER_GOALS', '$OPPONENT_GOALS')"
done