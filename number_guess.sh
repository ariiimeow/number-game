# This is a test comment to check Git change detection

#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

echo "Enter your username:"
read USERNAME

USERNAME_AVAIL=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")

GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games INNER JOIN users USING(user_id) WHERE username='$USERNAME'")

BEST_GAME=$($PSQL "SELECT MIN(number_guesses) FROM games INNER JOIN users USING(user_id) WHERE username='$USERNAME'")

if [[ -z $USERNAME_AVAIL ]]
then
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

RANDOM_NUM=$((1 + RANDOM % 1000))
GUESSES=1

echo "Guess the secret number between 1 and 1000:"

while read NUM
do
  if [[ ! $NUM =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    if [[ $NUM -eq $RANDOM_NUM ]]
    then
      break
    else
      if [[ $NUM -gt $RANDOM_NUM ]]
      then
        echo "It's lower than that, guess again:"
      else
        echo "It's higher than that, guess again:"
      fi
    fi
  fi
  GUESSES=$((GUESSES + 1))
done

echo "You guessed it in $GUESSES tries. The secret number was $RANDOM_NUM. Nice job!"

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
INSERT_GAME=$($PSQL "INSERT INTO games(number_guesses, user_id) VALUES($GUESSES, $USER_ID)")
