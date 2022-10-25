#! /bin/bash

# CREATE and UPDATE git repository
git_commit() {
    git add .
    git commit -m "$1"
}

cd ~/project
mkdir periodic_table
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

