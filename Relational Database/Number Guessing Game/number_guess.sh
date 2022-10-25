#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GET_USER(){
    # record username
    echo "Enter your username:"
    read USERNAME
    # until [[ ${#USERNAME} -ge 22 ]] 
    # do
    #   echo "Your username must has at least 22 characters, please enter your username again:"
    #   read USERNAME
    # done
    # search user in DB
    USER_RESULT=$($PSQL "select * from users where username='$USERNAME'")
    if [[ -z $USER_RESULT ]]
    then
      # if not exist, welcome and create new user in DB
      echo "Welcome, $USERNAME! It looks like this is your first time here."
      INSERT_USER_RESULT=$($PSQL "insert into users(username) values ('$USERNAME')")
      USER_ID=$($PSQL "select user_id from users where username='$USERNAME'")
    else
      # if exist, welcome with games detail
      USER_ID=$($PSQL "select user_id from users where username='$USERNAME'")
      PLAYED_GAMES_INFO=$($PSQL "select count(*) as total_games, min(guess_num) as best_guess_num from games where user_id=$USER_ID")
      echo "$PLAYED_GAMES_INFO" | while IFS='|' read TOTAL_GAMES BEST_GUESS_NUM
      do
        # echo "Welcome back, $USERNAME! You have played $TOTAL_GAMES games, and your best game took $BEST_GUESS_NUM guesses."
        if [[ $BEST_GUESS_NUM ==  1 ]]
        then
          guess_str="guess"
        else
          guess_str="guesses"
        fi
        if [[ $TOTAL_GAMES == 1 ]]
        then
          game_str="game"
        else
          game_str="games"
        fi
        echo -e "\nWelcome back, $USERNAME! You have played $TOTAL_GAMES $game_str, and your best game took $BEST_GUESS_NUM $guess_str."
      done
    fi
    
}

PLAY() {
    # generate random number from 1->1000
    RANDOM_NUMBER=$(($RANDOM % 1000 + 1))
    echo -e "\nGuess the secret number between 1 and 1000:"
    GUESS_NUMBER=-1
    number_of_guess=0

    while true
    do
      read GUESS_NUMBER
      ((number_of_guess+=1))
      if ! [[ $GUESS_NUMBER =~ ^[0-9]+$ ]]
      then
        echo -e "\nThat is not an integer, guess again:"
      elif [[ $GUESS_NUMBER == $RANDOM_NUMBER ]]
      then
        echo -e "\nYou guessed it in $number_of_guess tries. The secret number was $GUESS_NUMBER. Nice job!"
        break
      elif [[ $GUESS_NUMBER -gt $RANDOM_NUMBER ]]
      then
        echo -e "\nIt's lower than that, guess again:"
      else
        echo -e "\nIt's higher than that, guess again:"
      fi
      
    done

    
    
    # store games detail to DB
    INSERT_RESULT=$($PSQL "insert into games(user_id, guess_num) values($USER_ID, $number_of_guess)")
}


MAIN() {
    GET_USER
    PLAY
}


MAIN