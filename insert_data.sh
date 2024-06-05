#! /bin/bash

# if loop to run tests without affecting original database

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

#I'm going to start by emptying the rows in the tables of the database so I can rerun the file
echo $($PSQL "TRUNCATE TABLE games, teams")


#Next I'm reading the games.csv file using cat and applying a while loop to read row by row
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do

  # Time to insert data!

    # First, I need to get the winning team name

      #exclude column names row
      if [[ $WINNER != "winner" ]]
        then
          # get team name
          TEAM1_NAME=$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")
            #if team name is not found I need to include the new team to the table
            if [[ -z $TEAM1_NAME ]]
              then
              #insert new team
              INSERT_TEAM1_NAME=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
                #echo call to let me know team was inserted
                if [[ $INSERT_TEAM1_NAME == "INSERT 0 1" ]]
                  then
                    echo Inserted team $WINNER
                fi
            fi
      fi

    # Second, I need to get the opponent of the winner

      #exclude column names row
      if [[ $OPPONENT != "opponent" ]]
        then
          # get team name
          TEAM2_NAME=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")
            #if team name is not found I need to include the new team to the table
            if [[ -z $TEAM2_NAME ]]
              then
              #insert new team
              INSERT_TEAM2_NAME=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
                #echo call to let me know team was inserted
                if [[ $INSERT_TEAM2_NAME == "INSERT 0 1" ]]
                  then
                    echo Inserted team $OPPONENT
                fi
            fi
      fi

  # Third, I'm going to to add games data

    # I dont want the column names row so I'll exclude it
    if [[ YEAR != "year" ]]
      then
        #GET WINNER_ID
        WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
        #GET OPPONENT_ID
        OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
        #INSERT NEW GAMES ROW
        INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
          # echo call to let me know what was added
          if [[ $INSERT_GAME == "INSERT 0 1" ]]
            then
              echo New game added: $YEAR, $ROUND, $WINNER_ID VS $OPPONENT_ID, score $WINNER_GOALS : $OPPONENT_GOALS
          fi
    fi
    
done
