# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
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

# some editor aliases
alias vi='nvim'
alias vim='nvim'

# some termian aliases
alias tmux='tmux -u'

# aliases for Visual studio code
if [[ $(which code-insiders) && ! $(which code) ]]; then alias code=code-insiders; fi