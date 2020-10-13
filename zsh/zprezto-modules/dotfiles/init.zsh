#
# Enables tool specific aliases and functions config.
#

# Add zsh-completions to $fpath.
if [ -d "${DOTFILES_ETC_ZSH_COMPLETION_DIR}" ]; then
  fpath=("${DOTFILES_ETC_ZSH_COMPLETION_DIR}" $fpath)
fi

# Source alias files.
if [ -d  "${DOTFILES_ETC_ZSH_ALIAS_DIR}" ]; then
  for file in ${DOTFILES_ETC_ZSH_ALIAS_DIR}/*; do 
    source "$file"
  done
fi

# Source key-bindings files.
if [ -d  "${DOTFILES_ETC_ZSH_KEYBINDING_DIR}" ]; then
  for file in ${DOTFILES_ETC_ZSH_KEYBINDING_DIR}/*; do 
    source "$file"
  done
fi