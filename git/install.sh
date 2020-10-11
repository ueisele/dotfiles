#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(readlink -f $(dirname ${BASH_SOURCE[0]}))"
ROOT_DIR="$(readlink -f ${SCRIPT_DIR}/..)"
source ${ROOT_DIR}/env.sh
source ${ROOT_DIR}/function.log.sh
INSTALL_PACKAGE_BIN="${ROOT_DIR}/tool.install-package.sh"
LINK_DOTFILES_BIN="${ROOT_DIR}/tool.link-dotfiles.sh"

function userSigningKey () {
    gpg --with-colons -k "$(git config user.email)" 2>/dev/null | grep ":s:" | cut -d':' -f5
}

function ensure_git_is_configured () {
    log "INFO" "Configuring Git"
    ## User

    git config --global user.name "${USER_FULLNAME:-$(whoami)}"
    git config --global user.email "${USER_EMAIL:-$(whoami)@$(hostname)}"

    if [ ! -z $(userSigningKey) ]; then
        git config --global user.signingkey $(userSigningKey)
        git config --global commit.gpgsign true
    else
        git config --global --unset user.signingkey || true
        git config --global commit.gpgsign false
    fi

    ## Core

    git config --global core.autocrlf input
    git config --global core.excludesfile '~/.gitignore-global'

    ## Pull

    git config --global pull.rebase true

    ## Push

    git config --global push.default simple

    ## Diff & Merge

    git config --global merge.conflictstyle diff3
    git config --global mergetool.prompt false
    git config --global mergetool.keepTemporaries false
    git config --global mergetool.keepBackup false

    if command -v bcompare > /dev/null; then
        git config --global mergetool.bc3.trustExitCode true
        git config --global merge.tool bc3

        git config --global difftool.bc3.trustExitCode true
        git config --global diff.tool bc3
    elif command -v code > /dev/null; then
        git config --global mergetool.vscode.cmd "code --wait $MERGED"
        git config --global mergetool.vscode.trustExitCode false
        git config --global merge.tool vscode

        git config --global difftool.vscode.cmd "code --wait --diff $LOCAL $REMOTE"
        git config --global difftool.vscode.trustExitCode false
        git config --global diff.tool vscode
    elif command -v nvim > /dev/null; then 
        git config --global mergetool.vimdiff3.path nvim
        git config --global merge.tool vimdiff3

        git config --global difftool.vimdiff3.path nvim
        git config --global diff.tool vimdiff3
    elif command -v vim > /dev/null; then 
        git config --global merge.tool vimdiff3

        git config --global diff.tool vimdiff3
    else
        git config --global --unset merge.tool || true

        git config --global --unset diff.tool || true
    fi

    log "INFO" "Successfully configured Git"
}

function ensure_dotfiles_are_linked () {
    log "INFO" "Linking Git dotfiles to ${HOME}"
	${LINK_DOTFILES_BIN} "${SCRIPT_DIR}/files"
}

if command -v git &> /dev/null ; then
    ensure_git_is_configured
    ensure_dotfiles_are_linked
else
    log "INFO" "Skipping Git configuration, because git command is missing"
fi