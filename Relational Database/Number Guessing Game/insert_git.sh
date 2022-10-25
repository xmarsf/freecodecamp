#! /bin/bash

git_commit() {
    git add .
    git commit -m "$1"
}

cd ~/project
mkdir number_guessing_game
cd number_guessing_game
touch number_guess.sh; chmod +x number_guess.sh
git init
git checkout -b main

git add .
git commit -m "Initial commit"

touch test.txt
git_commit "fix: 2nd commit"

rm test.txt
git_commit "feat: 3rd commit"

touch test.txt
git_commit "refactor: 4th commit"

rm test.txt
git_commit "chore: 5th commit"
