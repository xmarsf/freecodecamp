#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=postgres -t --no-align -c"
$PSQL "drop database number_guess;"
$PSQL "create database number_guess;"
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

$PSQL "create table users(user_id serial primary key, username varchar not null, constraint username_unq unique (username))"
$PSQL "create table games(game_id serial primary key, user_id int not null references users(user_id), guess_num int not null)"