#! /usr/bin/env bash

MY_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

PLUGIN_DIRS="$HOME/go/src/github.com/eyedeekay/dungeonQuest
$HOME/go/src/github.com/eyedeekay/i2p-gemini
$HOME/go/src/github.com/eyedeekay/gneto
$HOME/go/src/i2pgit.org/idk/terrarium
$HOME/go/src/i2pgit.org/idk/reseed-tools
$HOME/go/src/i2pgit.org/idk/railroad
$HOME/go/src/i2pgit.org/idk/blizzard
$HOME/go/src/i2pgit.org/idk/i2p.plugins.tor-manager
"

#PLUGIN_DIRS="$HOME/go/src/i2pgit.org/idk/i2p.plugins.tor-manager
#"

GIT_REMOTE_NAME="origin"

for PLUGIN_DIR in $PLUGIN_DIRS; do
    cd "$PLUGIN_DIR" || exit 1
    git checkout main 2>/dev/null || git checkout trunk 2>/dev/null || git checkout master 2>/dev/null
    GIT_BRANCH_NAME=$(git branch | grep '*' | sed 's/* //')
    #pwd
    # ls
    # if a remote origin exists, use it instead
    # cut at the first tab
    if git remote -v | grep -q "eyedeekay"; then
        GIT_REMOTE_NAME=$(git remote -v | grep "eyedeekay" | tr '\t' ' ' | tr -d '\n' | cut -f1 -d' ')
    fi
    if git remote -v | grep -q "idk"; then
        GIT_REMOTE_NAME="$GIT_REMOTE_NAME "$(git remote -v | grep "idk" | tr '\t' ' ' | tr -d '\n' | cut -f1 -d' ')
    fi
    if git remote -v | grep "git@github" | grep -q "origin"; then
        GIT_REMOTE_NAME="$GIT_REMOTE_NAME "$(git remote -v | grep "origin" | tr '\t' ' ' | tr -d '\n' | cut -f1 -d' ')
    fi
    #git remote -v
    for GIT_REMOTE in $GIT_REMOTE_NAME; do
        if git remote -v | grep -q "$GIT_REMOTE"; then
            #git push "$GIT_REMOTE" "$GIT_BRANCH_NAME"
            git pull "$GIT_REMOTE" "$GIT_BRANCH_NAME"
            git commit -am "bulk release update"
            git push "$GIT_REMOTE" "$GIT_BRANCH_NAME"
            git push "$GIT_REMOTE" --all
            pwd
        fi
    done
    #get the last element of PLUGIN_DIR
    PLUGIN_NAME=$(echo "$PLUGIN_DIR" | rev | cut -f1 -d'/' | rev)
    grep -C 2 --color -Hn release Makefile > "$MY_SCRIPT_DIR/release-me-$PLUGIN_NAME.log"
    if grep -q "signer-dir" Makefile; then
        echo "signer-dir found"
        rm -fv "$MY_SCRIPT_DIR/release-fail-$PLUGIN_NAME.log" "$PLUGIN_DIR/hankhill"*.com
    else
        echo "signer-dir not found"
        grep -C 2 --color -Hn signer-dir Makefile >> "$MY_SCRIPT_DIR/release-fail-$PLUGIN_NAME.log"
    fi
    make all 2>&1 | tee "$MY_SCRIPT_DIR/release-build-$PLUGIN_NAME.log"
    make release 2>&1 | tee "$MY_SCRIPT_DIR/release-release-$PLUGIN_NAME.log"
done
