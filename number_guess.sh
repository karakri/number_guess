#!/bin/bash

#connect to database
PSQL="psql -X --username=freecodecamp --dbname=number_guess  -t --no-align --tuples-only -c"

#ask for a username
echo "Enter your username: "
read USERNAME

#lookup username in database
USER=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

if [[ -z $USER ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  #insert user in database
  INSERT_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
else
  #if username used, print Welcome back, <username>! You have played <games_played> games, and your best game took <best_game> guesses.
  N_GAMES=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USER")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id = $USER")
  echo "Welcome back, $USERNAME! You have played $N_GAMES games, and your best game took $BEST_GAME guesses."
fi

#create function PLAY_GAME
PLAY_GAME() {
#randomly generate a number between 1 and 1000
NUMBER=$(($(($RANDOM%1000))+1))

#print Guess the secret number between 1 and 1000:
echo "Guess the secret number between 1 and 1000:"
read GUESS
N_GUESSES=1
#while input does not equal number
while [[ $GUESS != $NUMBER ]]
do
  #increase number of guesses by 1
  N_GUESSES=$((N_GUESSES+1))
  #if input not a number, print That is not an integer, guess again:
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    read GUESS
  else
    #if input lower than number, print It's lower than that, guess again:
    if [ $NUMBER -lt $GUESS ]
    then
      echo "It's lower than that, guess again:"
      read GUESS
    else
      #if input higher than number, print It's higher than that, guess again:
      if [ $NUMBER -gt $GUESS ]
      then
        echo "It's higher than that, guess again:"
        read GUESS
      fi
      
    fi
    
  fi

done

#print the winning message
echo "You guessed it in $N_GUESSES tries. The secret number was $NUMBER. Nice job!"
#insert data about the game in the database
INSERT_RESULT=$($PSQL "INSERT INTO games(user_id, guesses) VALUES('$USER', $N_GUESSES)")

}

PLAY_GAME


