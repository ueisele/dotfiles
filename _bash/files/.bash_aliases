# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'

    alias diff='diff --color=auto'
fi

# some more ls aliases
alias l='ls -CF'
alias ll='ls -lh'
alias la='ls -A'
alias lla='ls -Alh'

# smome more aliases
alias cp="cp -i"                          # confirm before overwriting something
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias more=less

# aliases for Visual studio code
if [[ $(which code-insiders) && ! $(which code) ]]; then alias code=code-insiders; fi
