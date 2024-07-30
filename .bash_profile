export PATH="$PATH:~/bin"
export EDITOR=vim

# emacs shortcuts
set -o emacs

# httpserver
alias serve="python3 -m http.server"

# git
alias g="git"
alias gs="git status"
alias ga="git add"
alias gd="clear; git diff"
alias gc="git commit"
alias gca="git commit --amend"
alias gf="git fetch"
alias gp="git push"
alias gpnv="git push --no-verify"
alias gr="git pull --rebase"
alias gl="git log"

alias diffc="diff -b -y -W $(( $(tput cols) - 2 ))"

function gpu() {
	git push -u origin $(git rev-parse --abbrev-ref HEAD)
}

function gpunv() {
	git push --no-verify -u origin $(git rev-parse --abbrev-ref HEAD)
}

# diff the given commit against the previous commit
# $1 - commit hash to diff
function gdh() {
	git diff $1~1 $1
}

# edit a commit
# $1 - commit hash edit
function ge() {
	git stash
	git rebase --interactive $1~1
	git stash pop
}

# continue after editing commit
function gec() {
	git stash
	git rebase --continue
}

# move the specified file to the trash
function trash {
	mv "$@" ~/.Trash/
}

# nuke every node_modules folder in the current directory
# https://stackoverflow.com/a/59455542/1170723
function nukenode() {
  find . -name 'node_modules' -type d -prune -print -exec rm -rf '{}' \;
}

# go up a level
alias ..="cd .."

# perform an npm install in style
# $@ arguments to npm
function ni {
	afplay ~/.holdmusic.mp3 &
	ID=$!
	disown

	npm install $@
	kill -9 $ID
}

# perform a yarn install in style
# $@ arguments to yarn
function yi {
	afplay ~/.holdmusic.mp3 &
	ID=$!
	disown

	yarn install $@
	kill -9 $ID
}

# perform a yarn add in style
# $@ arguments to yarn
function ya {
	afplay ~/.holdmusic.mp3 &
	ID=$!
	disown

	yarn add $@
	kill -9 $ID
}

# start a verdaccio server
function fakenpm {
	killall -9 Verdaccio
	rm -rf /Users/lazd/.config/verdaccio/storage/
	npm set registry http://localhost:4873
	yarn config set registry http://localhost:4873

	verdaccio &

	sleep 2
	/usr/bin/expect <<EOD
spawn npm adduser
expect {
  "Username:" {send "lazd\r"; exp_continue}
  "Password:" {send "testpw\r"; exp_continue}
  "Email: (this IS public)" {send "lazdnet@gmail.com\r"; exp_continue}
}
EOD
}

# kill the verdaccio server, switch back to the real npm
function realnpm {
	killall -9 Verdaccio
	resetnpm
}

# reset the npm registry
function resetnpm {
	npm set registry https://registry.npmjs.org/
	yarn config set registry https://registry.yarnpkg.com
}

# rewrite the given commit to the given timestamp
# $1 commit hash
# $2 timestamp
rewrite_commit_date () {
  local commit="$1" date_timestamp="$2"
  local date temp_branch="temp-rebasing-branch"
  local current_branch="$(git rev-parse --abbrev-ref HEAD)"

  if [[ -z "$commit" ]]; then
      date=`date +'%a, %d %b %Y %H:%M:%S %z'`
  else
      date=`date -r "$date_timestamp" +'%a, %d %b %Y %H:%M:%S %z'`
  fi

  echo $date

  git checkout -b "$temp_branch" "$commit"
  GIT_COMMITTER_DATE="$date" git commit --amend --date "$date"
  git checkout "$current_branch"
  git rebase "$commit" --onto "$temp_branch"
  git branch -d "$temp_branch"
}

# rewrite the given commit to the given timestamp
# $1 old_email
# $2 new_name
# $3 new_email
rewrite_commit_author () {
  local old_email="$1" new_name="$2" new_email="$3" commit="$4"

  FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch --env-filter '
  WRONG_EMAIL="'"${old_email}"'"
  NEW_NAME="'"${new_name}"'"
  NEW_EMAIL="'"${new_email}"'"

  if [ "$GIT_COMMITTER_EMAIL" = "$WRONG_EMAIL" ]
  then
      export GIT_COMMITTER_NAME="$NEW_NAME"
      export GIT_COMMITTER_EMAIL="$NEW_EMAIL"
  fi
  if [ "$GIT_AUTHOR_EMAIL" = "$WRONG_EMAIL" ]
  then
      export GIT_AUTHOR_NAME="$NEW_NAME"
      export GIT_AUTHOR_EMAIL="$NEW_EMAIL"
  fi
  ' $commit..HEAD -- --branches --tags
}

# Find out WTF happened to the passed file
# $1 filepath
git_wtf () {
  git log --full-history -- $1
}

# Delete all local tags and fetch then authoritative copy from the remote
git_clear_tags () {
  git tag -l | xargs git tag -d
  git fetch --tags
}

# subfiles
DOTFILESDIR=$(dirname "$0")

source ${DOTFILESDIR}/.hz
