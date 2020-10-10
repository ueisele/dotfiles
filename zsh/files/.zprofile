#
# Executes commands at login pre-zshrc.
#

#
# Load ~/.profile
#
[[ ! -f ${HOME}/.profile ]] || emulate sh -c 'source ${HOME}/.profile'

#
# Load custom zprofile from ~/.zsh/zprofile.d
#
if [[ -d ${HOME}/.zsh/zprofile.d/ ]]; then
	for zprofile in ${HOME}/.zsh/zprofile.d/*.zsh(N); do
		test -r "$zprofile" && source "$zprofile"
	done
	unset zprofile
fi