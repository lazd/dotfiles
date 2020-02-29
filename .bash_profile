PATH="$PATH:~/bin"

# git
alias gs="git status"
alias ga="git add"
alias gd="git diff"
alias gc="git commit"
alias gca="git commit --amend"
alias gf="git fetch"
alias diffc="diff -b -y -W $(( $(tput cols) - 2 ))"

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
