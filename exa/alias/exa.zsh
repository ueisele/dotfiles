alias exa='exa --group-directories-first --git --icons --group'
alias el='exa -l'
alias ela='exa -la'

function ls () {
    # required because exa cannot list if symlinks are broken
    exa $@ 2> /dev/null || /bin/ls -h $@
}

alias ll='ls -l'
alias la='ls -la'