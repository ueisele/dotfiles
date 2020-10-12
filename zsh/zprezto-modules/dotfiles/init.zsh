#
# Enables tool specific aliases and functions config.
#

# Add zsh-completions to $fpath.
if [ -d "${DOTFILES_COMPLETIONS_ZSH_DIR}" ]; then
  fpath=("${DOTFILES_COMPLETIONS_ZSH_DIR}" $fpath)
fi

# Source alias files.
if [ -d  "${DOTFILES_ALIASES_DIR}" ]; then
  for file in ${DOTFILES_ALIASES_DIR}/*; do 
    source "$file"
  done
fi

# Source key-bindings files.
if [ -d  "${DOTFILES_KEYBINDINGS_ZSH_DIR}" ]; then
  for file in ${DOTFILES_KEYBINDINGS_ZSH_DIR}/*; do 
    source "$file"
  done
fi