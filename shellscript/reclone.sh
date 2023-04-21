# Script to reset local git repo as I am editing in test env. 
#   This will abandone local changes from my scratch directory and 
#   put a new version from github
# dan@dsblue.net  
#

git fetch 
git reset --hard HEAD
git merge '@{u}'
